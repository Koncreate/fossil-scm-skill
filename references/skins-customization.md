# Skins & Customization

## Overview

Fossil's web interface is skinnable. The skin controls the look and feel (HTML structure, CSS, JavaScript) without changing functionality. Skins are **local state** — they don't sync between repositories by default.

## Built-in Skins

Fossil ships with multiple built-in skins. Try them with:
```bash
fossil ui --skin default
fossil ui --skin blackbox
fossil ui --skin darkmode
```

Built-in skin sources are in the `skins/` folder of the Fossil source tree.

## Skin Structure

Each skin consists of 5 control files:

| File | Purpose |
|------|---------|
| `css.txt` | CSS styles for the page |
| `details.txt` | Settings controlling timeline appearance and colors |
| `header.txt` | HTML header (banner, menu bar) — processed as TH1 |
| `footer.txt` | HTML footer — processed as TH1 |
| `js.txt` | Optional JavaScript — must be included manually via TH1 |

## Page Structure

Every Fossil-generated HTML page follows this structure:

```
Fossil-Generated HTML Header
  <html>, <head>, <base>, <meta>, <title>, <link>
Skin Header (header.txt)
  <header>, <nav class="mainmenu">, custom HTML
Fossil-Generated Content
  <div class="content">
Skin Footer (footer.txt)
  <footer>, custom HTML
Fossil-Generated HTML Footer
  </body>, </html>
```

### Overriding the HTML Header

If your `header.txt` contains `<body`, Fossil assumes your skin handles the full HTML document structure and generates no automatic header/footer.

## Skin Files in Detail

### css.txt

The main CSS file. Fossil may append additional CSS if your file omits required components.

```css
/* Example: Change background color */
body {
    background-color: #1a1a2e;
    color: #eee;
}

/* Dark mode for timeline */
body.fossil-dark-style {
    background-color: #16213e;
}

/* Forum-specific styling */
body.forum div.markdown blockquote {
    margin-left: 10px;
    border-left: 3px solid #0f3460;
}
```

### details.txt

Controls timeline appearance and Pikchr diagram settings:

```tcl
pikchr-background:          "#ffffff"
pikchr-foreground:          "#000000"
pikchr-fontscale:           "1.0"
pikchr-scale:               "1.0"
timeline-arrowheads:        1
timeline-circle-nodes:      1
timeline-color-graph-lines: 1
white-foreground:           0
```

| Setting | Description |
|---------|-------------|
| `timeline-arrowheads` | Show arrowheads on timeline graph edges (1/0) |
| `timeline-circle-nodes` | Use circles for timeline nodes (1/0) |
| `timeline-color-graph-lines` | Color timeline graph lines (1/0) |
| `white-foreground` | Light text on dark background (1/0) |
| `pikchr-background` | Pikchr diagram background color |
| `pikchr-foreground` | Pikchr diagram foreground color |
| `pikchr-fontscale` | Pikchr font scaling factor |
| `pikchr-scale` | Pikchr overall scaling factor |

### header.txt

The most important file — contains the banner and menu bar. Processed as TH1.

```html
<header>
  <div class="title">
    <a href="$index_page">
      <img src="$logo_image" alt="Logo">
    </a>
    <h1>$projectname</h1>
  </div>
  <div class="status">
    <a href='/login'>Login</a>
  </div>
</header>
<nav class="mainmenu" title="Main Menu">
  <!-- Menu items set by Admin → Configuration → Main Menu -->
</nav>
```

### footer.txt

HTML footer content. Processed as TH1.

```html
<footer>
  <p>&copy; 2024 My Project — Powered by Fossil $fossil_version</p>
</footer>
```

### js.txt

Optional JavaScript. Must be included manually in header.txt or footer.txt:

```html
<!-- In footer.txt -->
<script nonce="$nonce">
  <th1>styleScript</th1>
</script>
```

Or for built-in JS files:
```html
<!-- In header.txt -->
<th1>builtin_request_js hbmenu.js</th1>
```

## TH1 Variables Available in Skins

| Variable | Description |
|----------|-------------|
| `$projectname` | Project name |
| `$index_page` | Index page URL |
| `$fossil_version` | Fossil version string |
| `$nonce` | CSP nonce for inline scripts |
| `$stylesheet_url` | URL of Fossil's built-in stylesheet |
| `$logo_image` | Logo image URL |

## Main Menu Customization

The main menu content is set separately from the skin (Admin → Configuration → Main Menu). This allows menu customizations to persist across skin changes.

Use TH1 conditions to show/hide menu items based on capabilities:
```html
<if {anycap 23456 || anoncap 2 || anoncap 3}>
  <a href='/forum'>Forum</a>
</if>
```

## Sharing Skins Between Repositories

```bash
# Export skin to file
fossil config export skin skin.txt

# Import skin from file
fossil config import skin.txt

# Pull skin from remote
fossil config pull skin

# Push skin to remote (requires admin on remote)
fossil config push skin

# Reset to default
fossil config reset skin
```

## Skin Development Workflow

1. **Create a draft skin** — Admin → Skin → initialize one of 9 draft skins
2. **Edit control files** — Modify css.txt, header.txt, footer.txt, details.txt, js.txt
3. **Test** — Preview the draft skin without affecting the live site
4. **Publish** — Make the draft skin the active skin

## Custom CSS Injection

For minor customizations, use the `css` setting instead of creating a full skin:

```bash
fossil set css "body { font-family: 'Inter', sans-serif; }"
```

This CSS is appended after the skin's css.txt.

## Custom Header/Footer HTML

For simple HTML injections:

```bash
fossil set header "<header><h1>My Project</h1></header>"
fossil set footer "<footer><p>&copy; 2024</p></footer>"
```

## Logo and Favicon

Store images as base64 in settings:

```bash
fossil set logo-image "data:image/png;base64,..."
fossil set logo-mimetype "image/png"
fossil set icon-image "data:image/x-icon;base64,..."
fossil set icon-mimetype "image/x-icon"
fossil set background-image "data:image/jpeg;base64,..."
fossil set background-mimetype "image/jpeg"
```

## Content Security Policy (CSP)

Fossil enforces CSP by default. Inline `<script>` tags will cause CSP errors unless they include the nonce:

```html
<script nonce="$nonce">
  // Your inline JavaScript here
</script>
```

For external scripts, add them via the skin's js.txt or use `builtin_request_js`.

## Custom Color Schemes

### Via Settings

```bash
fossil set css "\
  :root { --bg: #1a1a2e; --fg: #eee; --accent: #e94560; } \
  body { background: var(--bg); color: var(--fg); } \
  a { color: var(--accent); }"
```

### Via Skin CSS

```css
/* css.txt */
:root {
    --bg-primary: #0f3460;
    --bg-secondary: #16213e;
    --text-primary: #eee;
    --accent: #e94560;
}

body {
    background-color: var(--bg-secondary);
    color: var(--text-primary);
}

header {
    background-color: var(--bg-primary);
}

a, a:visited {
    color: var(--accent);
}
```

## Per-Page CSS Classes

Fossil adds feature-specific CSS classes to the `<body>` tag:

| Class | Page |
|-------|------|
| `body.forum` | Forum pages |
| `body.cpage-doc` | Embedded documentation |
| `body.cpage-timeline` | Timeline |
| `body.cpage-wiki` | Wiki pages |
| `body.cpage-tktview` | Ticket view |
| `body.cpage-login` | Login page |
| `body.fossil-dark-style` | Dark mode active |

Use these for per-feature styling:
```css
body.forum div.markdown blockquote {
    border-left: 3px solid #0f3460;
}

body.cpage-timeline td.timelineGraph {
    background: #f5f5f5;
}
```
