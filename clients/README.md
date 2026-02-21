# UmbaLabs 3D - Client Tracking

## How to Use

### Adding a New Client
1. Copy `_template/` folder → rename with kebab-case project name
2. Fill in `profile.md` with client details
3. Create `files/` and `photos/` subdirectories as needed
4. Start `notes.md` for communication log

### Naming Convention
Use **kebab-case** based on the project: `client-project-description`
- `prado-radio-trim`
- `hilux-phone-mount`
- `office-desk-organizer`

### Folder Structure
```
clients/
├── _template/          # Copy for new clients
│   └── profile.md
└── <project-name>/
    ├── profile.md      # Client & project details
    ├── files/          # STLs, 3MF, design files
    ├── photos/         # Reference photos from client
    └── notes.md        # Communication log
```

### Status Flow
`Quote` → `In Progress` → `Printing` → `Done` → `Delivered`
