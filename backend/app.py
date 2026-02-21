"""
UmbaLabs 3D - File Upload API with Instant Quoting
===================================================
Features:
- STL file parsing (binary and ASCII)
- Instant volume calculation and pricing
- Analytics tracking
- Telegram notifications
"""

import os
import struct
import math
import sqlite3
import logging
import numpy as np
from datetime import datetime, timedelta
from functools import wraps
from flask import Flask, request, jsonify, g
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash
import requests
import json
import jwt

# =============================================================================
# Configuration
# =============================================================================

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

app = Flask(__name__)
app.config.update(
    UPLOAD_FOLDER=os.path.join(BASE_DIR, 'uploads'),
    DATABASE=os.path.join(BASE_DIR, 'data', 'umbalabs3d.db'),
    MAX_CONTENT_LENGTH=100 * 1024 * 1024,  # 100MB
)

ALLOWED_EXTENSIONS = {'stl'}
TELEGRAM_BOT_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN', '')
TELEGRAM_CHAT_ID = os.environ.get('TELEGRAM_CHAT_ID', '')
JWT_SECRET = os.environ.get('JWT_SECRET')
if not JWT_SECRET:
    raise RuntimeError("JWT_SECRET environment variable must be set")

# Pricing configuration (KES per gram + print time)
PRICING = {
    'PLA': {
        'rate': 15,          # KES per gram
        'time_rate': 120,    # KES per hour
        'setup_fee': 0,
        'min_price': 500,    # Minimum order
        'name': 'PLA',
        'description': 'Standard material, good for prototypes and decorative items',
        'colors': ['White', 'Black', 'Red', 'Blue', 'Green', 'Yellow', 'Orange'],
        'lead_time': '2-3 days'
    },
    'PETG': {
        'rate': 20,
        'time_rate': 150,
        'setup_fee': 0,
        'min_price': 600,
        'name': 'PETG',
        'description': 'Stronger and more durable, ideal for functional parts',
        'colors': ['White', 'Black', 'Clear', 'Blue'],
        'lead_time': '2-3 days'
    },
    'TPU': {
        'rate': 25,
        'time_rate': 180,
        'setup_fee': 0,
        'min_price': 700,
        'name': 'TPU (Flexible)',
        'description': 'Flexible and impact resistant, ideal for grips and gaskets',
        'colors': ['Black', 'Grey'],
        'lead_time': '3-4 days'
    }
}

# Material estimate configuration (heuristic slicer-based estimate)
MATERIAL_ESTIMATES = {
    'PLA': {
        'density_g_cm3': 1.24,
        'volumetric_rate_mm3_s': 12.0,
        'infill': 0.20,
        'shell_thickness_mm': 1.2,
        'base_minutes': 10
    },
    'PETG': {
        'density_g_cm3': 1.27,
        'volumetric_rate_mm3_s': 10.0,
        'infill': 0.20,
        'shell_thickness_mm': 1.2,
        'base_minutes': 12
    },
    'TPU': {
        'density_g_cm3': 1.21,
        'volumetric_rate_mm3_s': 6.0,
        'infill': 0.25,
        'shell_thickness_mm': 1.2,
        'base_minutes': 15
    }
}

PRINT_LIMITS = {
    'build_volume_mm': {'x': 256, 'y': 256, 'z': 256},
    'nozzle_mm': 0.4,
    'layer_height_mm': {'min': 0.08, 'max': 0.28},
    'fdm_min_wall_mm': 1.5,
    'sla_min_wall_mm': 1.0,
    'tolerance_mm': {'small': 0.2, 'large_percent': 0.2}
}

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(os.path.join(BASE_DIR, 'logs', 'app.log')),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


# =============================================================================
# STL Parser (Pure Python + NumPy)
# =============================================================================

class STLParser:
    """Parse STL files (binary and ASCII) and calculate mesh properties."""
    
    @staticmethod
    def parse(file_content):
        """
        Parse STL file content and return triangles.
        Returns: numpy array of shape (n_triangles, 3, 3) representing vertices
        """
        # Check if binary or ASCII
        if STLParser._is_binary(file_content):
            return STLParser._parse_binary(file_content)
        else:
            return STLParser._parse_ascii(file_content)
    
    @staticmethod
    def _is_binary(content):
        """Check if STL is binary (not ASCII)."""
        # ASCII STL starts with 'solid'
        try:
            header = content[:80].decode('utf-8', errors='ignore').lower()
            if header.startswith('solid'):
                # Could still be binary with 'solid' in header
                # Check if we can find 'facet' keyword
                text = content[:1000].decode('utf-8', errors='ignore').lower()
                if 'facet' in text and 'normal' in text:
                    return False
            return True
        except:
            return True
    
    @staticmethod
    def _parse_binary(content):
        """Parse binary STL format."""
        # Binary STL format:
        # 80 bytes header
        # 4 bytes: number of triangles (uint32)
        # For each triangle:
        #   12 bytes: normal vector (3 x float32)
        #   36 bytes: vertices (3 x 3 x float32)
        #   2 bytes: attribute byte count (uint16)
        
        header = content[:80]
        num_triangles = struct.unpack('<I', content[80:84])[0]
        
        triangles = np.zeros((num_triangles, 3, 3), dtype=np.float32)
        
        offset = 84
        for i in range(num_triangles):
            # Skip normal (12 bytes)
            offset += 12
            
            # Read 3 vertices (36 bytes)
            for v in range(3):
                x, y, z = struct.unpack('<fff', content[offset:offset+12])
                triangles[i, v] = [x, y, z]
                offset += 12
            
            # Skip attribute (2 bytes)
            offset += 2
        
        return triangles
    
    @staticmethod
    def _parse_ascii(content):
        """Parse ASCII STL format."""
        text = content.decode('utf-8', errors='ignore')
        lines = text.split('\n')
        
        triangles = []
        current_triangle = []
        
        for line in lines:
            line = line.strip().lower()
            if line.startswith('vertex'):
                parts = line.split()
                if len(parts) >= 4:
                    vertex = [float(parts[1]), float(parts[2]), float(parts[3])]
                    current_triangle.append(vertex)
                    
                    if len(current_triangle) == 3:
                        triangles.append(current_triangle)
                        current_triangle = []
        
        return np.array(triangles, dtype=np.float32)
    
    @staticmethod
    def calculate_volume(triangles):
        """
        Calculate mesh volume using signed tetrahedron method.
        Each triangle forms a tetrahedron with the origin.
        """
        if len(triangles) == 0:
            return 0.0
        
        # Signed volume of tetrahedron formed by triangle and origin
        # V = (1/6) * |a · (b × c)|
        v0 = triangles[:, 0, :]
        v1 = triangles[:, 1, :]
        v2 = triangles[:, 2, :]
        
        # Cross product of edges
        cross = np.cross(v1 - v0, v2 - v0)
        
        # Dot product with first vertex (forms tetrahedron with origin)
        volume = np.sum(v0 * cross) / 6.0
        
        return abs(volume)
    
    @staticmethod
    def calculate_bounding_box(triangles):
        """Calculate bounding box dimensions."""
        if len(triangles) == 0:
            return {'x': 0, 'y': 0, 'z': 0}
        
        # Flatten to get all vertices
        vertices = triangles.reshape(-1, 3)
        
        min_coords = np.min(vertices, axis=0)
        max_coords = np.max(vertices, axis=0)
        
        dimensions = max_coords - min_coords
        
        return {
            'x': float(dimensions[0]),
            'y': float(dimensions[1]),
            'z': float(dimensions[2]),
            'min': {'x': float(min_coords[0]), 'y': float(min_coords[1]), 'z': float(min_coords[2])},
            'max': {'x': float(max_coords[0]), 'y': float(max_coords[1]), 'z': float(max_coords[2])}
        }
    
    @staticmethod
    def calculate_surface_area(triangles):
        """Calculate total surface area."""
        if len(triangles) == 0:
            return 0.0
        
        v0 = triangles[:, 0, :]
        v1 = triangles[:, 1, :]
        v2 = triangles[:, 2, :]
        
        # Area = 0.5 * |cross product of two edges|
        cross = np.cross(v1 - v0, v2 - v0)
        areas = 0.5 * np.linalg.norm(cross, axis=1)
        
        return float(np.sum(areas))

    @staticmethod
    def check_mesh_quality(triangles, max_triangles=200000, precision=4):
        """Basic manifold + degenerate triangle checks."""
        result = {
            'checked': False,
            'reason': None,
            'boundary_edges': 0,
            'non_manifold_edges': 0,
            'degenerate_triangles': 0
        }

        if len(triangles) == 0:
            result['reason'] = 'no_triangles'
            return result

        if len(triangles) > max_triangles:
            result['reason'] = 'too_many_triangles'
            return result

        v0 = triangles[:, 0, :]
        v1 = triangles[:, 1, :]
        v2 = triangles[:, 2, :]
        cross = np.cross(v1 - v0, v2 - v0)
        areas = 0.5 * np.linalg.norm(cross, axis=1)
        result['degenerate_triangles'] = int(np.sum(areas < 1e-6))

        edges = {}

        def q(vertex):
            return tuple(np.round(vertex, precision))

        for tri in triangles:
            a, b, c = q(tri[0]), q(tri[1]), q(tri[2])
            for e1, e2 in ((a, b), (b, c), (c, a)):
                if e1 == e2:
                    continue
                edge = (e1, e2) if e1 <= e2 else (e2, e1)
                edges[edge] = edges.get(edge, 0) + 1

        result['boundary_edges'] = sum(1 for count in edges.values() if count == 1)
        result['non_manifold_edges'] = sum(1 for count in edges.values() if count > 2)
        result['checked'] = True
        return result
    
    @staticmethod
    def check_printability(triangles, bounding_box, material_key='PLA'):
        """Check if model is printable and return issues."""
        issues = []
        warnings = []
        
        # Check if mesh has triangles
        if len(triangles) == 0:
            issues.append("File contains no geometry")
            return {'printable': False, 'issues': issues, 'warnings': warnings}
        
        # Check dimensions against build volume
        max_build = PRINT_LIMITS['build_volume_mm']
        
        if bounding_box['x'] > max_build['x']:
            issues.append(f"Too wide: {bounding_box['x']:.1f}mm exceeds {max_build['x']}mm")
        if bounding_box['y'] > max_build['y']:
            issues.append(f"Too deep: {bounding_box['y']:.1f}mm exceeds {max_build['y']}mm")
        if bounding_box['z'] > max_build['z']:
            issues.append(f"Too tall: {bounding_box['z']:.1f}mm exceeds {max_build['z']}mm")
        
        # Check for very small models
        min_dimension = min(bounding_box['x'], bounding_box['y'], bounding_box['z'])
        if min_dimension < 1:
            warnings.append("Very small model - may lack detail")
        
        # Check for thin features (rough estimate)
        volume_mm3 = STLParser.calculate_volume(triangles)
        surface_area = STLParser.calculate_surface_area(triangles)
        
        if surface_area > 0 and volume_mm3 > 0:
            # Characteristic thickness estimate
            thickness_estimate = volume_mm3 / surface_area
            min_wall = PRINT_LIMITS['fdm_min_wall_mm']
            if thickness_estimate < (min_wall * 0.6):
                warnings.append("Thin walls detected (heuristic) - may be fragile")
        
        # Check triangle count for complexity
        if len(triangles) > 500000:
            warnings.append("High polygon count - may slow processing")

        mesh = STLParser.check_mesh_quality(triangles)
        if mesh['checked']:
            if mesh['boundary_edges'] > 0:
                warnings.append("Open edges detected (non-manifold geometry)")
            if mesh['non_manifold_edges'] > 0:
                warnings.append("Non-manifold edges detected")
            if mesh['degenerate_triangles'] > 0:
                warnings.append("Degenerate triangles detected")
        else:
            warnings.append("Mesh too complex for full manifold check")
        
        printable = len(issues) == 0
        
        return {
            'printable': printable,
            'issues': issues,
            'warnings': warnings,
            'triangle_count': len(triangles),
            'mesh': mesh
        }


# =============================================================================
# Database
# =============================================================================

def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect(app.config['DATABASE'])
        g.db.row_factory = sqlite3.Row
    return g.db

@app.teardown_appcontext
def close_db(exception):
    db = g.pop('db', None)
    if db is not None:
        db.close()

def init_db():
    os.makedirs(os.path.dirname(app.config['DATABASE']), exist_ok=True)

    with sqlite3.connect(app.config['DATABASE']) as conn:
        conn.executescript('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                phone TEXT UNIQUE NOT NULL,
                name TEXT NOT NULL,
                password_hash TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_login TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS uploads (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                filename TEXT NOT NULL,
                original_filename TEXT NOT NULL,
                file_size INTEGER NOT NULL,
                file_type TEXT,
                user_id INTEGER REFERENCES users(id),
                customer_name TEXT,
                customer_phone TEXT,
                ip_address TEXT,
                user_agent TEXT,
                utm_source TEXT,
                utm_medium TEXT,
                utm_campaign TEXT,
                utm_content TEXT,
                utm_term TEXT,
                status TEXT DEFAULT 'pending',
                quote_amount REAL,
                selected_material TEXT,
                volume_cm3 REAL,
                dimensions TEXT,
                units TEXT,
                estimated_grams REAL,
                estimated_hours REAL,
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS analytics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                event_type TEXT NOT NULL,
                page TEXT,
                referrer TEXT,
                ip_address TEXT,
                user_agent TEXT,
                session_id TEXT,
                metadata TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS page_views (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date DATE NOT NULL,
                page TEXT NOT NULL,
                views INTEGER DEFAULT 1,
                unique_visitors INTEGER DEFAULT 1,
                UNIQUE(date, page)
            );

            CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
            CREATE INDEX IF NOT EXISTS idx_uploads_created ON uploads(created_at);
            CREATE INDEX IF NOT EXISTS idx_uploads_user ON uploads(user_id);
            CREATE INDEX IF NOT EXISTS idx_analytics_created ON analytics(created_at);
        ''')
        ensure_schema(conn)
        logger.info("Database initialized")

def ensure_schema(conn):
    """Add missing columns for upgrades."""
    cursor = conn.execute("PRAGMA table_info(uploads)")
    existing = {row[1] for row in cursor.fetchall()}
    additions = {
        'units': 'TEXT',
        'estimated_grams': 'REAL',
        'estimated_hours': 'REAL',
        'utm_source': 'TEXT',
        'utm_medium': 'TEXT',
        'utm_campaign': 'TEXT',
        'utm_content': 'TEXT',
        'utm_term': 'TEXT'
    }
    for column, col_type in additions.items():
        if column not in existing:
            conn.execute(f'ALTER TABLE uploads ADD COLUMN {column} {col_type}')
            logger.info(f"Added uploads.{column} column")


# =============================================================================
# Helpers
# =============================================================================

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_extension(filename):
    return filename.rsplit('.', 1)[1].upper() if '.' in filename else 'UNKNOWN'

def normalize_units(units):
    units = (units or 'mm').strip().lower()
    if units in ('mm', 'millimeter', 'millimeters'):
        return 'mm', 1.0
    if units in ('in', 'inch', 'inches'):
        return 'in', 25.4
    if units in ('cm', 'centimeter', 'centimeters'):
        return 'cm', 10.0
    return 'mm', 1.0

def format_size(bytes):
    if bytes < 1024:
        return f"{bytes} B"
    elif bytes < 1024 * 1024:
        return f"{bytes / 1024:.1f} KB"
    else:
        return f"{bytes / (1024 * 1024):.2f} MB"

def get_client_ip():
    if request.headers.get('X-Forwarded-For'):
        return request.headers.get('X-Forwarded-For').split(',')[0].strip()
    return request.remote_addr

def estimate_print(volume_mm3, surface_area_mm2, bounding_box, material_key):
    cfg = MATERIAL_ESTIMATES.get(material_key, MATERIAL_ESTIMATES['PLA'])
    density = cfg['density_g_cm3']
    shell_volume_mm3 = surface_area_mm2 * cfg['shell_thickness_mm']
    infill_volume_mm3 = volume_mm3 * cfg['infill']
    print_volume_mm3 = min(volume_mm3, shell_volume_mm3 + infill_volume_mm3)
    time_seconds = (print_volume_mm3 / cfg['volumetric_rate_mm3_s']) + cfg['base_minutes'] * 60

    grams = (print_volume_mm3 / 1000.0) * density
    hours = time_seconds / 3600.0

    return {
        'grams': round(float(grams), 1),
        'hours': round(float(hours), 1),
        'print_volume_cm3': round(float(print_volume_mm3 / 1000.0), 1),
        'source': 'heuristic'
    }

def round_price(amount, step=50):
    return int(math.ceil(amount / step) * step)

def build_limitations(material_key):
    min_wall = PRINT_LIMITS['fdm_min_wall_mm']
    limits = [
        f"Max build size: {PRINT_LIMITS['build_volume_mm']['x']}×{PRINT_LIMITS['build_volume_mm']['y']}×{PRINT_LIMITS['build_volume_mm']['z']} mm",
        f"Min wall thickness: {min_wall:.1f} mm",
        "Nozzle: 0.4 mm standard",
        "Materials: PLA, PETG, TPU",
        f"Typical tolerance: ±{PRINT_LIMITS['tolerance_mm']['small']:.1f} mm (for <100 mm parts)",
        "STL files only (units must be correct)"
    ]
    limits.append("FDM parts are weaker across layers (Z-direction)")
    return {
        'limits': limits,
        'build_volume_mm': PRINT_LIMITS['build_volume_mm'],
        'min_wall_mm': min_wall,
        'tolerance_mm': PRINT_LIMITS['tolerance_mm'],
        'layer_height_mm': PRINT_LIMITS['layer_height_mm'],
        'nozzle_mm': PRINT_LIMITS['nozzle_mm']
    }

def calculate_prices(volume_cm3, volume_mm3=None, surface_area_mm2=None, bounding_box=None):
    """Calculate final prices for all materials based on estimated grams and time."""
    prices = {}
    for material, config in PRICING.items():
        estimate = None
        grams = None
        hours = None
        if volume_mm3 is not None and surface_area_mm2 is not None and bounding_box is not None:
            estimate = estimate_print(volume_mm3, surface_area_mm2, bounding_box, material)
            grams = estimate['grams']
            hours = estimate['hours']
        if grams is None:
            grams = volume_cm3 * 1.0
        if hours is None:
            hours = max(0.1, grams / 15.0)
        raw_price = (grams * config['rate']) + (hours * config['time_rate']) + config.get('setup_fee', 0)
        final_price = max(raw_price, config['min_price'])
        final_price = round_price(final_price, 50)
        prices[material] = {
            'price': round(final_price, 0),
            'rate': config['rate'],
            'time_rate': config['time_rate'],
            'setup_fee': config.get('setup_fee', 0),
            'min_price': config['min_price'],
            'name': config['name'],
            'description': config['description'],
            'colors': config['colors'],
            'lead_time': config['lead_time'],
            'estimate': estimate
        }
    return prices

# =============================================================================
# Authentication Helpers
# =============================================================================

def create_token(user_id):
    """Create JWT token with 30-day expiry."""
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(days=30)
    }
    return jwt.encode(payload, JWT_SECRET, algorithm='HS256')


def verify_token(token):
    """Verify JWT token and return user_id or None."""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
        return payload['user_id']
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None


def auth_required(f):
    """Decorator requiring valid JWT token."""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization', '')
        token = auth_header.replace('Bearer ', '') if auth_header.startswith('Bearer ') else ''
        user_id = verify_token(token)
        if not user_id:
            return jsonify({'success': False, 'error': 'Unauthorized'}), 401
        g.user_id = user_id
        return f(*args, **kwargs)
    return decorated


def auth_optional(f):
    """Decorator that sets g.user_id if token provided, but doesn't require it."""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization', '')
        token = auth_header.replace('Bearer ', '') if auth_header.startswith('Bearer ') else ''
        g.user_id = verify_token(token)  # None if not authenticated
        return f(*args, **kwargs)
    return decorated


def send_telegram(upload_data):
    if not TELEGRAM_BOT_TOKEN or not TELEGRAM_CHAT_ID:
        return False

    volume_str = f"{upload_data.get('volume_cm3', 0):.1f} cm³" if upload_data.get('volume_cm3') else "N/A"
    material_str = upload_data.get('selected_material', 'Not selected')
    quote_str = f"KES {upload_data.get('quote_amount', 0):,.0f}" if upload_data.get('quote_amount') else "Pending"

    msg = f"""📤 *New 3D Print Request*

📁 *File:* `{upload_data['original_filename']}`
📊 *Size:* {format_size(upload_data['file_size'])}
📐 *Volume:* {volume_str}
🎨 *Material:* {material_str}
💰 *Quote:* {quote_str}

👤 *Name:* {upload_data['customer_name']}
📱 *Phone:* {upload_data['customer_phone']}
⏰ *Time:* {datetime.now().strftime('%Y-%m-%d %H:%M')}
🆔 *Upload ID:* #{upload_data['id']}

Contact customer on WhatsApp to confirm order."""

    try:
        response = requests.post(
            f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage",
            json={'chat_id': TELEGRAM_CHAT_ID, 'text': msg, 'parse_mode': 'Markdown'},
            timeout=10
        )
        return response.status_code == 200
    except Exception as e:
        logger.error(f"Telegram error: {e}")
        return False


# =============================================================================
# API Routes - Authentication
# =============================================================================

@app.route('/api/auth/register', methods=['POST'])
def register():
    """Register a new user with phone + password."""
    data = request.get_json() or {}
    phone = data.get('phone', '').strip()
    name = data.get('name', '').strip()
    password = data.get('password', '')

    # Validation
    if not phone or not name or not password:
        return jsonify({'success': False, 'error': 'Phone, name, and password are required'}), 400

    if len(password) < 6:
        return jsonify({'success': False, 'error': 'Password must be at least 6 characters'}), 400

    # Normalize phone (remove spaces, leading zeros for +254)
    phone = phone.replace(' ', '').replace('-', '')
    if phone.startswith('0'):
        phone = '254' + phone[1:]
    elif phone.startswith('+'):
        phone = phone[1:]

    db = get_db()

    # Check if phone already exists
    existing = db.execute('SELECT id FROM users WHERE phone = ?', (phone,)).fetchone()
    if existing:
        return jsonify({'success': False, 'error': 'Phone number already registered'}), 400

    # Create user
    password_hash = generate_password_hash(password)
    cursor = db.execute(
        'INSERT INTO users (phone, name, password_hash) VALUES (?, ?, ?)',
        (phone, name, password_hash)
    )
    db.commit()
    user_id = cursor.lastrowid

    logger.info(f"New user registered: {name} ({phone})")

    # Create token
    token = create_token(user_id)

    return jsonify({
        'success': True,
        'token': token,
        'user': {'id': user_id, 'phone': phone, 'name': name}
    }), 201


@app.route('/api/auth/login', methods=['POST'])
def login():
    """Login with phone + password."""
    data = request.get_json() or {}
    phone = data.get('phone', '').strip()
    password = data.get('password', '')

    if not phone or not password:
        return jsonify({'success': False, 'error': 'Phone and password are required'}), 400

    # Normalize phone
    phone = phone.replace(' ', '').replace('-', '')
    if phone.startswith('0'):
        phone = '254' + phone[1:]
    elif phone.startswith('+'):
        phone = phone[1:]

    db = get_db()
    user = db.execute(
        'SELECT id, phone, name, password_hash FROM users WHERE phone = ?',
        (phone,)
    ).fetchone()

    if not user or not check_password_hash(user['password_hash'], password):
        return jsonify({'success': False, 'error': 'Invalid phone or password'}), 401

    # Update last_login
    db.execute('UPDATE users SET last_login = ? WHERE id = ?',
               (datetime.now().isoformat(), user['id']))
    db.commit()

    logger.info(f"User login: {user['name']} ({user['phone']})")

    token = create_token(user['id'])

    return jsonify({
        'success': True,
        'token': token,
        'user': {'id': user['id'], 'phone': user['phone'], 'name': user['name']}
    }), 200


@app.route('/api/auth/me', methods=['GET'])
@auth_required
def get_current_user():
    """Get current authenticated user info."""
    db = get_db()
    user = db.execute(
        'SELECT id, phone, name, created_at FROM users WHERE id = ?',
        (g.user_id,)
    ).fetchone()

    if not user:
        return jsonify({'success': False, 'error': 'User not found'}), 404

    return jsonify({
        'id': user['id'],
        'phone': user['phone'],
        'name': user['name'],
        'created_at': user['created_at']
    }), 200


@app.route('/api/user/uploads', methods=['GET'])
@auth_required
def get_user_uploads():
    """Get uploads for the authenticated user."""
    db = get_db()
    uploads = db.execute('''
        SELECT id, original_filename, status, quote_amount, selected_material,
               volume_cm3, dimensions, created_at
        FROM uploads
        WHERE user_id = ?
        ORDER BY created_at DESC
    ''', (g.user_id,)).fetchall()

    return jsonify({
        'uploads': [{
            'id': u['id'],
            'original_filename': u['original_filename'],
            'status': u['status'],
            'quote_amount': u['quote_amount'],
            'selected_material': u['selected_material'],
            'volume_cm3': u['volume_cm3'],
            'dimensions': u['dimensions'],
            'created_at': u['created_at']
        } for u in uploads]
    }), 200


# =============================================================================
# API Routes - Instant Quote
# =============================================================================

@app.route('/api/quote', methods=['POST'])
def instant_quote():
    """
    Analyze uploaded STL file and return instant quote.
    No account required, no data saved.
    """
    if 'file' not in request.files:
        return jsonify({'success': False, 'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'success': False, 'error': 'No file selected'}), 400

    # Units (STL is unitless - default to mm)
    units_raw = request.form.get('units', 'mm')
    units, scale_factor = normalize_units(units_raw)

    # Check extension
    ext = get_extension(file.filename)
    if ext != 'STL':
        return jsonify({
            'success': False,
            'error': 'Only STL files are supported for instant final quotes. Please convert your file to STL.',
            'file_type': ext
        }), 400

    try:
        # Read file content
        content = file.read()
        file_size = len(content)
        
        # Parse STL
        if ext == 'STL':
            triangles = STLParser.parse(content)
            if scale_factor != 1.0:
                triangles = triangles * scale_factor
            
            # Calculate properties
            volume_mm3 = STLParser.calculate_volume(triangles)
            volume_cm3 = volume_mm3 / 1000  # Convert to cm³
            
            bounding_box = STLParser.calculate_bounding_box(triangles)
            surface_area = STLParser.calculate_surface_area(triangles)
            printability = STLParser.check_printability(triangles, bounding_box)
            
            # Calculate prices
            prices = calculate_prices(volume_cm3, volume_mm3, surface_area, bounding_box)
            
            # Estimate print time (fallback heuristic)
            estimated_hours = max(0.5, volume_cm3 / 20)
            estimated_grams = None
            default_estimate = prices.get('PLA', {}).get('estimate')
            if default_estimate:
                estimated_hours = default_estimate.get('hours', estimated_hours)
                estimated_grams = default_estimate.get('grams')

            # Unit confirmation hint
            max_dim = max(bounding_box['x'], bounding_box['y'], bounding_box['z'])
            unit_warning = None
            if max_dim < 5:
                unit_warning = "Model seems very small. Was it designed in inches?"
            elif max_dim > 500:
                unit_warning = "Model seems very large. Confirm your units."

            # Display dimensions in selected units
            if units == 'in':
                display_dims = {
                    'x': bounding_box['x'] / 25.4,
                    'y': bounding_box['y'] / 25.4,
                    'z': bounding_box['z'] / 25.4
                }
            elif units == 'cm':
                display_dims = {
                    'x': bounding_box['x'] / 10.0,
                    'y': bounding_box['y'] / 10.0,
                    'z': bounding_box['z'] / 10.0
                }
            else:
                display_dims = {
                    'x': bounding_box['x'],
                    'y': bounding_box['y'],
                    'z': bounding_box['z']
                }
            
            # Track analytics (convert numpy types to Python types)
            track_event('instant_quote', metadata={
                'file_type': ext,
                'volume_cm3': float(round(volume_cm3, 2)),
                'printable': bool(printability['printable']),
                'units': units
            })

            limitations = {
                material: build_limitations(material) for material in PRICING.keys()
            }

            return jsonify({
                'success': True,
                'supported': True,
                'file': {
                    'name': file.filename,
                    'size': file_size,
                    'size_formatted': format_size(file_size),
                    'type': ext
                },
                'analysis': {
                    'volume_mm3': float(round(volume_mm3, 2)),
                    'volume_cm3': float(round(volume_cm3, 2)),
                    'dimensions': {
                        'x': float(round(display_dims['x'], 2)),
                        'y': float(round(display_dims['y'], 2)),
                        'z': float(round(display_dims['z'], 2))
                    },
                    'dimensions_mm': {
                        'x': float(round(bounding_box['x'], 2)),
                        'y': float(round(bounding_box['y'], 2)),
                        'z': float(round(bounding_box['z'], 2))
                    },
                    'display_unit': units,
                    'unit_warning': unit_warning,
                    'surface_area_mm2': float(round(surface_area, 2)),
                    'triangle_count': int(len(triangles)),
                    'estimated_print_hours': float(round(estimated_hours, 1)),
                    'estimated_grams': float(round(estimated_grams, 1)) if estimated_grams is not None else None
                },
                'printability': printability,
                'limitations': limitations,
                'prices': prices,
                'currency': 'KES'
            }), 200


    except Exception as e:
        logger.error(f"Quote analysis error: {e}")
        return jsonify({
            'success': False,
            'error': 'Could not analyze file. Please check the STL and try again.'
        }), 500


# =============================================================================
# API Routes - File Upload
# =============================================================================

@app.route('/api/upload', methods=['POST'])
@auth_optional
def upload_file():
    """Handle 3D file upload with optional pre-calculated quote."""
    if 'file' not in request.files:
        return jsonify({'success': False, 'error': 'No file provided'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'success': False, 'error': 'No file selected'}), 400

    if not allowed_file(file.filename):
        return jsonify({'success': False, 'error': 'Only STL files are supported for instant final quotes.'}), 400

    try:
        customer_name = request.form.get('name', '').strip() or 'Not provided'
        customer_phone = request.form.get('phone', '').strip() or 'Not provided'
        selected_material = request.form.get('material', '').strip() or None
        quote_amount = request.form.get('quote_amount', type=float) or None
        volume_cm3 = request.form.get('volume_cm3', type=float) or None
        dimensions = request.form.get('dimensions', '').strip() or None
        units = request.form.get('units', '').strip() or None
        estimated_grams = request.form.get('estimated_grams', type=float) or None
        estimated_hours = request.form.get('estimated_hours', type=float) or None
        utm_source = request.form.get('utm_source', '').strip() or None
        utm_medium = request.form.get('utm_medium', '').strip() or None
        utm_campaign = request.form.get('utm_campaign', '').strip() or None
        utm_content = request.form.get('utm_content', '').strip() or None
        utm_term = request.form.get('utm_term', '').strip() or None

        # Get user_id if authenticated
        user_id = getattr(g, 'user_id', None)

        # Save file
        original_filename = file.filename
        safe_filename = secure_filename(original_filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        saved_filename = f"{timestamp}_{safe_filename}"

        os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], saved_filename)
        file.save(filepath)

        file_size = os.path.getsize(filepath)
        file_type = get_extension(original_filename)

        # Save to database
        db = get_db()
        cursor = db.execute('''
            INSERT INTO uploads (filename, original_filename, file_size, file_type,
                                user_id, customer_name, customer_phone, ip_address, user_agent,
                                utm_source, utm_medium, utm_campaign, utm_content, utm_term,
                                selected_material, quote_amount, volume_cm3, dimensions,
                                units, estimated_grams, estimated_hours)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (saved_filename, original_filename, file_size, file_type,
              user_id, customer_name, customer_phone, get_client_ip(),
              request.headers.get('User-Agent', ''),
              utm_source, utm_medium, utm_campaign, utm_content, utm_term,
              selected_material, quote_amount, volume_cm3, dimensions,
              units, estimated_grams, estimated_hours))
        db.commit()
        upload_id = cursor.lastrowid

        logger.info(f"Upload #{upload_id}: {original_filename} ({format_size(file_size)}) - {selected_material or 'No material'}")

        track_event('upload_complete', metadata={
            'upload_id': upload_id,
            'file_type': file_type,
            'has_quote': quote_amount is not None
        })

        send_telegram({
            'id': upload_id,
            'original_filename': original_filename,
            'file_size': file_size,
            'file_type': file_type,
            'customer_name': customer_name,
            'customer_phone': customer_phone,
            'volume_cm3': volume_cm3,
            'selected_material': selected_material,
            'quote_amount': quote_amount
        })

        response_msg = 'Order received!' if quote_amount else 'File uploaded!'
        response_msg += ' We will contact you on WhatsApp shortly.'

        return jsonify({
            'success': True,
            'message': response_msg,
            'upload_id': upload_id,
            'quote_amount': quote_amount,
            'material': selected_material
        }), 200

    except Exception as e:
        logger.error(f"Upload error: {e}")
        return jsonify({'success': False, 'error': 'Upload failed. Please try WhatsApp.'}), 500


# =============================================================================
# API Routes - Analytics
# =============================================================================

def track_event(event_type, page=None, metadata=None, session_id=None):
    try:
        db = get_db()
        db.execute('''
            INSERT INTO analytics (event_type, page, referrer, ip_address, user_agent, session_id, metadata)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            event_type,
            page or request.path,
            request.headers.get('Referer', ''),
            get_client_ip(),
            request.headers.get('User-Agent', ''),
            session_id,
            json.dumps(metadata) if metadata else None
        ))
        db.commit()
    except Exception as e:
        logger.error(f"Analytics error: {e}")

@app.route('/api/track', methods=['POST'])
def track_pageview():
    data = request.get_json() or {}
    event_type = data.get('event', 'pageview')
    page = data.get('page', '/')
    metadata = data.get('metadata', {})
    session_id = data.get('session_id')

    track_event(event_type, page, metadata, session_id)

    if event_type == 'pageview':
        try:
            db = get_db()
            today = datetime.now().strftime('%Y-%m-%d')
            db.execute('''
                INSERT INTO page_views (date, page, views, unique_visitors)
                VALUES (?, ?, 1, 1)
                ON CONFLICT(date, page) DO UPDATE SET views = views + 1
            ''', (today, page))
            db.commit()
        except Exception as e:
            logger.error(f"Page view error: {e}")

    return jsonify({'success': True}), 200

@app.route('/api/stats', methods=['GET'])
def get_stats():
    db = get_db()
    now = datetime.now()
    today = now.strftime('%Y-%m-%d')
    week_ago = (now - timedelta(days=7)).strftime('%Y-%m-%d')

    uploads_today = db.execute('SELECT COUNT(*) FROM uploads WHERE DATE(created_at) = ?', (today,)).fetchone()[0]
    uploads_week = db.execute('SELECT COUNT(*) FROM uploads WHERE DATE(created_at) >= ?', (week_ago,)).fetchone()[0]
    uploads_total = db.execute('SELECT COUNT(*) FROM uploads').fetchone()[0]
    
    views_today = db.execute('SELECT COALESCE(SUM(views), 0) FROM page_views WHERE date = ?', (today,)).fetchone()[0]
    views_week = db.execute('SELECT COALESCE(SUM(views), 0) FROM page_views WHERE date >= ?', (week_ago,)).fetchone()[0]

    recent_uploads = db.execute('''
        SELECT id, original_filename, file_size, customer_name, customer_phone, 
               status, quote_amount, selected_material, volume_cm3, created_at
        FROM uploads ORDER BY created_at DESC LIMIT 10
    ''').fetchall()

    return jsonify({
        'uploads': {'today': uploads_today, 'week': uploads_week, 'total': uploads_total},
        'pageviews': {'today': views_today, 'week': views_week},
        'recent_uploads': [{
            'id': u['id'],
            'filename': u['original_filename'],
            'size': format_size(u['file_size']),
            'customer': u['customer_name'],
            'phone': u['customer_phone'],
            'status': u['status'],
            'quote': u['quote_amount'],
            'material': u['selected_material'],
            'volume': u['volume_cm3'],
            'date': u['created_at']
        } for u in recent_uploads],
        'generated_at': now.isoformat()
    }), 200

@app.route('/api/analytics/dashboard', methods=['GET'])
def analytics_dashboard():
    """Comprehensive analytics dashboard data."""
    try:
        db = get_db()
        now = datetime.now()

        # --- Date range filter ---
        range_param = request.args.get('range', '30d')
        if range_param == 'today':
            since = now.strftime('%Y-%m-%d')
        elif range_param == '7d':
            since = (now - timedelta(days=7)).strftime('%Y-%m-%d')
        elif range_param == 'all':
            since = '2000-01-01'
        else:  # default 30d
            since = (now - timedelta(days=30)).strftime('%Y-%m-%d')

        # === OVERVIEW CARDS ===
        total_pageviews = db.execute(
            'SELECT COALESCE(SUM(views), 0) FROM page_views WHERE date >= ?', (since,)
        ).fetchone()[0]

        unique_sessions = db.execute(
            'SELECT COUNT(DISTINCT session_id) FROM analytics WHERE created_at >= ? AND session_id IS NOT NULL', (since,)
        ).fetchone()[0]

        registered_users = db.execute('SELECT COUNT(*) FROM users').fetchone()[0]

        total_uploads = db.execute(
            'SELECT COUNT(*) FROM uploads WHERE created_at >= ?', (since,)
        ).fetchone()[0]

        quotes_generated = db.execute(
            "SELECT COUNT(*) FROM analytics WHERE event_type IN ('quote_generated', 'instant_quote') AND created_at >= ?", (since,)
        ).fetchone()[0]

        orders_submitted = db.execute(
            "SELECT COUNT(*) FROM analytics WHERE event_type = 'order_submitted' AND created_at >= ?", (since,)
        ).fetchone()[0]

        # === DAILY VISITORS CHART (always 30 days) ===
        thirty_days_ago = (now - timedelta(days=30)).strftime('%Y-%m-%d')
        daily_visitors = db.execute(
            'SELECT date, SUM(views) as total_views FROM page_views WHERE date >= ? GROUP BY date ORDER BY date', (thirty_days_ago,)
        ).fetchall()

        # === CONVERSION FUNNEL ===
        funnel_stages = ['pageview', 'section_view', 'cta_click', 'upload_start', 'upload_complete', 'quote_generated', 'instant_quote', 'order_submitted']
        funnel_data = {}
        for stage in funnel_stages:
            count = db.execute(
                "SELECT COUNT(*) FROM analytics WHERE event_type = ? AND created_at >= ?", (stage, since)
            ).fetchone()[0]
            if count > 0:
                funnel_data[stage] = count

        # === EVENT TYPE BREAKDOWN ===
        event_types = db.execute(
            'SELECT event_type, COUNT(*) as count FROM analytics WHERE created_at >= ? GROUP BY event_type ORDER BY count DESC',
            (since,)
        ).fetchall()

        # === DEVICE BREAKDOWN ===
        user_agents = db.execute(
            'SELECT user_agent FROM analytics WHERE created_at >= ? AND user_agent IS NOT NULL', (since,)
        ).fetchall()

        devices = {'Mobile': 0, 'Desktop': 0, 'Tablet': 0}
        for row in user_agents:
            ua = (row['user_agent'] or '').lower()
            if any(k in ua for k in ['mobile', 'android', 'iphone']):
                devices['Mobile'] += 1
            elif any(k in ua for k in ['ipad', 'tablet']):
                devices['Tablet'] += 1
            else:
                devices['Desktop'] += 1

        # === TOP REFERRERS ===
        referrers = db.execute(
            "SELECT referrer, COUNT(*) as count FROM analytics WHERE created_at >= ? AND referrer IS NOT NULL AND referrer != '' GROUP BY referrer ORDER BY count DESC LIMIT 10",
            (since,)
        ).fetchall()

        # === UTM SOURCES ===
        utm_sources = db.execute(
            "SELECT utm_source, COUNT(*) as count FROM uploads WHERE created_at >= ? AND utm_source IS NOT NULL AND utm_source != '' GROUP BY utm_source ORDER BY count DESC LIMIT 10",
            (since,)
        ).fetchall()

        # === POPULAR MATERIALS ===
        materials = db.execute(
            "SELECT selected_material, COUNT(*) as count FROM uploads WHERE created_at >= ? AND selected_material IS NOT NULL GROUP BY selected_material ORDER BY count DESC",
            (since,)
        ).fetchall()

        # === CTA CLICKS (parse metadata JSON) ===
        cta_rows = db.execute(
            "SELECT metadata FROM analytics WHERE event_type = 'cta_click' AND created_at >= ? AND metadata IS NOT NULL",
            (since,)
        ).fetchall()

        cta_clicks = {}
        for row in cta_rows:
            try:
                meta = json.loads(row['metadata'])
                button = meta.get('button') or meta.get('text') or meta.get('label') or 'Unknown'
                cta_clicks[button] = cta_clicks.get(button, 0) + 1
            except (json.JSONDecodeError, TypeError):
                pass

        # === SCROLL DEPTH (parse metadata JSON) ===
        scroll_rows = db.execute(
            "SELECT metadata FROM analytics WHERE event_type = 'scroll' AND created_at >= ? AND metadata IS NOT NULL",
            (since,)
        ).fetchall()

        scroll_depth = {'25%': 0, '50%': 0, '75%': 0, '100%': 0}
        for row in scroll_rows:
            try:
                meta = json.loads(row['metadata'])
                depth = str(meta.get('depth', ''))
                key = f"{depth}%" if not depth.endswith('%') else depth
                if key in scroll_depth:
                    scroll_depth[key] += 1
            except (json.JSONDecodeError, TypeError):
                pass

        # === HOURLY DISTRIBUTION ===
        hourly = db.execute(
            "SELECT strftime('%%H', created_at) as hour, COUNT(*) as count FROM analytics WHERE created_at >= ? GROUP BY hour ORDER BY hour",
            (since,)
        ).fetchall()

        # === RECENT ACTIVITY ===
        recent = db.execute(
            'SELECT event_type, page, referrer, session_id, metadata, created_at FROM analytics ORDER BY created_at DESC LIMIT 20'
        ).fetchall()

        return jsonify({
            'overview': {
                'pageviews': total_pageviews,
                'sessions': unique_sessions,
                'users': registered_users,
                'uploads': total_uploads,
                'quotes': quotes_generated,
                'orders': orders_submitted,
            },
            'daily_visitors': [{'date': r['date'], 'views': r['total_views']} for r in daily_visitors],
            'funnel': funnel_data,
            'event_types': [{'type': r['event_type'], 'count': r['count']} for r in event_types],
            'devices': devices,
            'referrers': [{'referrer': r['referrer'], 'count': r['count']} for r in referrers],
            'utm_sources': [{'source': r['utm_source'], 'count': r['count']} for r in utm_sources],
            'materials': [{'material': r['selected_material'], 'count': r['count']} for r in materials],
            'cta_clicks': cta_clicks,
            'scroll_depth': scroll_depth,
            'hourly': [{'hour': r['hour'], 'count': r['count']} for r in hourly],
            'recent_activity': [{
                'event': r['event_type'],
                'page': r['page'],
                'referrer': r['referrer'],
                'session': r['session_id'],
                'metadata': r['metadata'],
                'time': r['created_at']
            } for r in recent],
            'range': range_param,
            'generated_at': now.isoformat()
        }), 200

    except Exception as e:
        logger.error(f"Analytics dashboard error: {e}")
        return jsonify({'error': 'Failed to load analytics'}), 500

@app.route('/api/uploads', methods=['GET'])
def list_uploads():
    db = get_db()
    limit = min(int(request.args.get('limit', 50)), 100)
    uploads = db.execute('SELECT * FROM uploads ORDER BY created_at DESC LIMIT ?', (limit,)).fetchall()

    return jsonify({
        'uploads': [{
            'id': u['id'],
            'filename': u['original_filename'],
            'size': format_size(u['file_size']),
            'file_type': u['file_type'],
            'customer_name': u['customer_name'],
            'customer_phone': u['customer_phone'],
            'status': u['status'],
            'quote_amount': u['quote_amount'],
            'selected_material': u['selected_material'],
            'volume_cm3': u['volume_cm3'],
            'created_at': u['created_at']
        } for u in uploads],
        'count': len(uploads)
    }), 200

@app.route('/api/uploads/<int:upload_id>', methods=['GET', 'PATCH'])
def manage_upload(upload_id):
    db = get_db()
    
    if request.method == 'GET':
        upload = db.execute('SELECT * FROM uploads WHERE id = ?', (upload_id,)).fetchone()
        if not upload:
            return jsonify({'error': 'Upload not found'}), 404
        return jsonify({k: upload[k] for k in upload.keys()}), 200

    elif request.method == 'PATCH':
        data = request.get_json() or {}
        allowed = ['status', 'quote_amount', 'notes', 'selected_material']
        updates = {k: v for k, v in data.items() if k in allowed}
        
        if not updates:
            return jsonify({'error': 'No valid fields'}), 400

        set_clause = ', '.join(f"{k} = ?" for k in updates.keys())
        values = list(updates.values()) + [datetime.now().isoformat(), upload_id]
        
        db.execute(f'UPDATE uploads SET {set_clause}, updated_at = ? WHERE id = ?', values)
        db.commit()
        
        return jsonify({'success': True, 'updated': list(updates.keys())}), 200


# =============================================================================
# API Routes - Health & Pricing Info
# =============================================================================

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'service': 'UmbaLabs 3D API',
        'version': '4.0',
        'features': ['instant_quote', 'stl_parsing', 'analytics', 'user_auth'],
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/api/pricing', methods=['GET'])
def get_pricing():
    """Return current pricing configuration."""
    return jsonify({
        'materials': PRICING,
        'currency': 'KES',
        'notes': [
            'Prices are estimates based on volume',
            'Complex geometries may cost more',
            'Bulk discounts available for 5+ items'
        ]
    }), 200

@app.errorhandler(413)
def file_too_large(e):
    return jsonify({'success': False, 'error': 'File too large. Maximum 100MB.'}), 413

@app.errorhandler(500)
def internal_error(e):
    logger.error(f"Internal error: {e}")
    return jsonify({'success': False, 'error': 'Server error.'}), 500


# =============================================================================
# Startup
# =============================================================================

if __name__ == '__main__':
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    os.makedirs(os.path.join(BASE_DIR, 'logs'), exist_ok=True)
    init_db()
    
    logger.info("=" * 50)
    logger.info("UmbaLabs 3D API v4.0 - User Auth + Instant Quoting")
    logger.info(f"Upload folder: {app.config['UPLOAD_FOLDER']}")
    logger.info(f"Database: {app.config['DATABASE']}")
    logger.info(f"Telegram: {'configured' if TELEGRAM_BOT_TOKEN else 'not configured'}")
    logger.info("JWT: configured from environment")
    logger.info("=" * 50)
    
    app.run(host='127.0.0.1', port=5000, debug=False)
