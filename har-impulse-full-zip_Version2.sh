#!/usr/bin/env bash
# HAR Impulse — Full explicit ZIP-creation script
# Writes every theme file verbatim into ./har-impulse-theme/ and creates har-impulse-theme.zip
#
# Usage:
#   1) Create or cd to an empty directory where you want to generate the ZIP.
#   2) Save this file as har-impulse-full-zip.sh
#   3) chmod +x har-impulse-full-zip.sh
#   4) ./har-impulse-full-zip.sh
#
# Output:
#   ./har-impulse-theme.zip (contains the theme folder har-impulse-theme/)
#
set -euo pipefail

OUTDIR="har-impulse-theme"
ZIPNAME="har-impulse-theme.zip"

if [ -d "$OUTDIR" ] || [ -f "$ZIPNAME" ]; then
  echo "Warning: $OUTDIR or $ZIPNAME already exists."
  read -p "Overwrite (y/N)? " confirm
  if [ "${confirm,,}" != "y" ]; then
    echo "Aborting."
    exit 1
  fi
  rm -rf "$OUTDIR" "$ZIPNAME"
fi

mkdir -p "$OUTDIR"/{layout,templates,templates/customers,sections,snippets,assets,config,locales}

# --------------------------
# layout/theme.liquid
# --------------------------
cat > "$OUTDIR/layout/theme.liquid" <<'EOF'
<!doctype html>
<html lang="{{ request.locale }}">
  <head>
    <!-- Basic meta + SEO placeholders -->
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <meta name="theme-color" content="{{ settings.theme_color | default: '#111' }}">
    <title>{% if page_title %}{{ page_title }} — {% endif %}{{ shop.name }}</title>

    <!-- Shopify required tags -->
    {{ content_for_header }}

    <!-- Performance: preload critical fonts and the main CSS -->
    <link rel="preload" href="{{ 'main.css' | asset_url }}" as="style">
    <link rel="stylesheet" href="{{ 'main.css' | asset_url }}" />

    <!-- Inline critical CSS (small) -->
    <style>
      :root{
        --brand:#111;
        --accent:#b08b59;
        --muted:#6b6b6b;
        --bg:#ffffff;
        --text:#111111;
        --radius:6px;
      }
      [data-theme="dark"]{ --bg:#0b0b0b; --text:#f7f7f7; --muted:#9b9b9b; }
      html,body{ background:var(--bg); color:var(--text); -webkit-font-smoothing:antialiased; font-family: 'Inter', system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial; }
      /* Sticky header placeholder height to avoid content jump */
      .header-sticky-ghost{ height:72px; }
    </style>

    <!-- JSON-LD basic store schema for SEO -->
    <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "Store",
        "name": "{{ shop.name | escape }}",
        "url": "{{ shop.url }}",
        "description": "{{ shop.description | escape }}"
      }
    </script>
  </head>

  <body class="har-impulse" data-theme="{{ settings.default_theme | default: 'light' }}">
    <!-- Header -->
    {% section 'header' %}

    <!-- Sticky header spacer -->
    <div id="shopify-section-main" class="header-sticky-ghost" aria-hidden="true"></div>

    <!-- Main content -->
    <main id="MainContent" role="main">
      {{ content_for_layout }}
    </main>

    <!-- Footer -->
    {% section 'footer' %}

    <!-- Quick view modal and templates -->
    {% render 'quick-view' %}

    <!-- Shopify footer scripts -->
    {{ content_for_footer }}

    <!-- Vendor & theme scripts -->
    <script src="{{ 'vendor-lazyload.js' | asset_url }}" defer></script>
    <script src="{{ 'theme.js' | asset_url }}" type="module" defer></script>

    <!-- Inline small script for theme mode toggle (fast) -->
    <script>
      (function(){
        const root = document.documentElement;
        const stored = localStorage.getItem('har-theme') || document.body.getAttribute('data-theme');
        if(stored) document.body.setAttribute('data-theme', stored);
        document.addEventListener('theme:toggle', (e)=> {
          const t = document.body.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
          document.body.setAttribute('data-theme', t);
          localStorage.setItem('har-theme', t);
        });
      })();
    </script>
  </body>
</html>
EOF

# --------------------------
# templates/*.json and .liquid
# --------------------------
cat > "$OUTDIR/templates/index.json" <<'EOF'
{
  "sections": {
    "hero": {
      "type": "hero",
      "settings": {}
    },
    "featured_collections": {
      "type": "featured-collections",
      "settings": {}
    },
    "slideshow": {
      "type": "slideshow",
      "settings": {}
    },
    "trending_products": {
      "type": "product-grid",
      "settings": {
        "title": "Trending"
      }
    },
    "testimonial": {
      "type": "testimonials",
      "settings": {}
    },
    "instagram": {
      "type": "instagram-feed",
      "settings": {}
    },
    "newsletter": {
      "type": "newsletter",
      "settings": {}
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "hero",
    "featured_collections",
    "slideshow",
    "trending_products",
    "testimonial",
    "instagram",
    "newsletter",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/product.json" <<'EOF'
{
  "sections": {
    "product": {
      "type": "product-template",
      "settings": {}
    },
    "recommended": {
      "type": "product-grid",
      "settings": {
        "title": "You may also like",
        "source": "recommendations"
      }
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "product",
    "recommended",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/collection.json" <<'EOF'
{
  "sections": {
    "collection": {
      "type": "collection-template",
      "settings": {}
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "collection",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/page.about.json" <<'EOF'
{
  "sections": {
    "about": {
      "type": "about",
      "settings": {}
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "about",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/page.contact.json" <<'EOF'
{
  "sections": {
    "contact-form": {
      "type": "contact-form",
      "settings": {}
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "contact-form",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/blog.json" <<'EOF'
{
  "sections": {
    "blog_list": {
      "type": "blog-list",
      "settings": {}
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "blog_list",
    "footer"
  ]
}
EOF

# customers templates
cat > "$OUTDIR/templates/customers/account.json" <<'EOF'
{
  "sections": {
    "account": {
      "type": "account",
      "settings": {}
    },
    "account-orders": {
      "type": "account-orders",
      "settings": {}
    },
    "account-addresses": {
      "type": "account-addresses",
      "settings": {}
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "account",
    "account-orders",
    "account-addresses",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/customers/login.json" <<'EOF'
{
  "sections": {
    "account-login": {
      "type": "account-login",
      "settings": {
        "mode": "login"
      }
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "account-login",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/customers/register.json" <<'EOF'
{
  "sections": {
    "account-login": {
      "type": "account-login",
      "settings": {
        "mode": "register"
      }
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "account-login",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/customers/reset_password.json" <<'EOF'
{
  "sections": {
    "account-login": {
      "type": "account-login",
      "settings": {
        "mode": "reset"
      }
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "account-login",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/customers/addresses.json" <<'EOF'
{
  "sections": {
    "account-addresses": {
      "type": "account-addresses",
      "settings": {}
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "account-addresses",
    "footer"
  ]
}
EOF

cat > "$OUTDIR/templates/product.quick.liquid" <<'EOF'
{% comment %}
Alternate product view returned by quick view fetch.
This file outputs only the section markup (no full layout) so it can be loaded via fetch.
Used by quick-view snippet which fetches /products/{{ handle }}?view=quick or /products/{{ id }}?view=quick
{% endcomment %}
{% section 'product-quick' %}
EOF

cat > "$OUTDIR/templates/product.alternate.json" <<'EOF'
{
  "sections": {
    "product": {
      "type": "product-template",
      "settings": {
        "layout_variant": "alternate"
      }
    },
    "recommended": {
      "type": "product-grid",
      "settings": {
        "title": "Customers also bought",
        "source": "recommendations",
        "limit": 8
      }
    },
    "footer": {
      "type": "footer",
      "settings": {}
    }
  },
  "order": [
    "product",
    "recommended",
    "footer"
  ]
}
EOF

# --------------------------
# sections/*.liquid
# --------------------------
cat > "$OUTDIR/sections/header.liquid" <<'EOF'
{% comment %}
Premium sticky header with logo, search, currency, and cart.
Supports mega menu via navigation lists and nested items.
{% endcomment %}

<header id="shopify-section-header" class="site-header" role="banner" data-sticky="{{ section.settings.sticky_header }}">
  <div class="header-inner container">
    <div class="brand">
      <a href="{{ shop.url }}" class="logo" aria-label="{{ shop.name }}">
        {% if section.settings.logo != blank %}
          <img src="{{ section.settings.logo | image_url: width: 400 }}" alt="{{ shop.name }}" />
        {% else %}
          <span class="brand-text">{{ shop.name }}</span>
        {% endif %}
      </a>
    </div>

    <nav class="main-nav" role="navigation" aria-label="Main menu">
      {% comment %}
      Render a navigation menu named in settings (supports mega menu items with "menu-item" metafields)
      {% endcomment %}
      {% assign menu_handle = section.settings.main_menu %}
      {% if menu_handle %}
        {% assign main_menu = linklists[menu_handle] %}
        <ul class="menu-level-1">
          {% for item in main_menu.links %}
            <li class="menu-item{% if item.links.size > 0 %} has-children{% endif %}">
              <a href="{{ item.url }}" class="menu-link">{{ item.title }}</a>
              {% if item.links.size > 0 %}
                <div class="mega-menu">
                  <div class="mega-columns">
                    {% for child in item.links %}
                      <div class="mega-column">
                        <a href="{{ child.url }}" class="mega-title">{{ child.title }}</a>
                        {% if child.links.size > 0 %}
                          <ul>
                            {% for g in child.links %}
                              <li><a href="{{ g.url }}">{{ g.title }}</a></li>
                            {% endfor %}
                          </ul>
                        {% endif %}
                      </div>
                    {% endfor %}
                  </div>
                </div>
              {% endif %}
            </li>
          {% endfor %}
        </ul>
      {% endif %}
    </nav>

    <div class="header-controls">
      <button class="header-icon search-trigger" aria-label="Search" data-action="open-search">
        {% render 'icon-search' %}
      </button>

      {% render 'currency-selector' %}

      <a href="/cart" class="header-icon cart-link" aria-label="Cart">
        {% render 'icon-cart' %}
        <span class="cart-count" data-cart-count>{{ cart.item_count }}</span>
      </a>

      <button class="btn-theme-toggle" aria-label="Toggle theme" onclick="document.dispatchEvent(new Event('theme:toggle'))">
        {{ '🌓' }}
      </button>
    </div>
  </div>

  <!-- Search drawer (lightweight) -->
  <div class="search-drawer" data-drawer="search" hidden>
    <form action="/search" method="get" role="search" class="search-form">
      <input type="search" name="q" placeholder="Search products, brands and more..." aria-label="Search">
      <button type="submit">Search</button>
    </form>
  </div>

  <style>
    /* Minimal styles for header - override in main CSS */
    .site-header{ position:sticky; top:0; z-index:60; background:var(--bg); border-bottom:1px solid rgba(0,0,0,0.04); }
    .header-inner{ display:flex; align-items:center; justify-content:space-between; gap:1rem; padding:16px; max-width:1200px; margin:0 auto; }
    .main-nav .menu-level-1{ display:flex; gap:1rem; list-style:none; margin:0; padding:0; }
    .menu-item{ position:relative; }
    .mega-menu{ position:absolute; left:0; top:100%; background:var(--bg); padding:20px; box-shadow:0 10px 30px rgba(0,0,0,0.08); display:none; width:720px; }
    .menu-item:hover .mega-menu{ display:block; }
    .header-controls{ display:flex; align-items:center; gap:0.5rem; }
    .cart-count{ background:var(--accent); color:#fff; border-radius:999px; font-size:12px; padding:2px 6px; margin-left:6px; }
  </style>
</header>

{% schema %}
{
  "name": "Header",
  "settings": [
    { "type": "image_picker", "id": "logo", "label": "Logo" },
    { "type": "link_list", "id": "main_menu", "label": "Main navigation" },
    { "type": "checkbox", "id": "sticky_header", "label": "Sticky header", "default": true }
  ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/footer.liquid" <<'EOF'
{% comment %}
Multi-column footer with newsletter and social icons.
{% endcomment %}
<footer class="site-footer" role="contentinfo">
  <div class="footer-top container">
    <div class="footer-columns">
      <div class="col">
        <h4>{{ settings.footer_title_1 }}</h4>
        {% if settings.footer_menu_1 %}
          <ul>
            {% for link in linklists[settings.footer_menu_1].links %}
              <li><a href="{{ link.url }}">{{ link.title }}</a></li>
            {% endfor %}
          </ul>
        {% endif %}
      </div>
      <div class="col">
        <h4>{{ settings.footer_title_2 }}</h4>
        {% if settings.footer_menu_2 %}
          <ul>
            {% for link in linklists[settings.footer_menu_2].links %}
              <li><a href="{{ link.url }}">{{ link.title }}</a></li>
            {% endfor %}
          </ul>
        {% endif %}
      </div>
      <div class="col">
        <h4>{{ settings.footer_title_3 }}</h4>
        <p>{{ settings.contact_info }}</p>
      </div>
      <div class="col">
        <h4>Newsletter</h4>
        {% section 'newsletter' %}
        <div class="socials">
          {% render 'social-icons' %}
        </div>
      </div>
    </div>
  </div>

  <div class="footer-bottom">
    <div class="container">
      <p>&copy; {{ 'now' | date: '%Y' }} {{ shop.name }} · {{ shop.country }}</p>
    </div>
  </div>

  <style>
    .site-footer{ border-top:1px solid rgba(0,0,0,0.04); padding:40px 0; color:var(--muted); }
    .footer-columns{ display:grid; grid-template-columns:repeat(4,1fr); gap:24px; }
    .footer-bottom{ padding-top:16px; border-top:1px solid rgba(0,0,0,0.03); margin-top:24px; }
    @media(max-width:800px){ .footer-columns{ grid-template-columns:1fr 1fr; } }
  </style>
</footer>

{% schema %}
{
  "name": "Footer",
  "settings": [
    { "type": "text", "id": "footer_title_1", "label": "Column 1 title", "default": "Shop" },
    { "type": "link_list", "id": "footer_menu_1", "label": "Column 1 menu" },
    { "type": "text", "id": "footer_title_2", "label": "Column 2 title", "default": "Company" },
    { "type": "link_list", "id": "footer_menu_2", "label": "Column 2 menu" },
    { "type": "text", "id": "footer_title_3", "label": "Column 3 title", "default": "Contact" },
    { "type": "textarea", "id": "contact_info", "label": "Contact info", "default": "support@example.com\n+1 555 555 5555" }
  ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/hero.liquid" <<'EOF'
{% comment %}
Hero banner with overlay, CTA, and optional background image or video.
{% endcomment %}

<section class="hero-section" aria-label="Hero banner" data-section-id="{{ section.id }}">
  <div class="hero-inner container">
    <div class="hero-media">
      {% if section.settings.image != blank %}
        <picture>
          <img src="{{ section.settings.image | image_url: width: 2000 }}" alt="{{ section.settings.alt_text }}" loading="lazy" />
        </picture>
      {% endif %}
    </div>
    <div class="hero-content">
      <h1>{{ section.settings.heading }}</h1>
      <p class="sub">{{ section.settings.subheading }}</p>
      {% if section.settings.cta_label != blank and section.settings.cta_url != blank %}
        <a href="{{ section.settings.cta_url }}" class="btn btn-primary">{{ section.settings.cta_label }}</a>
      {% endif %}
    </div>
  </div>

  <style>
    .hero-section{ display:flex; align-items:center; justify-content:center; padding:60px 0; position:relative; overflow:hidden; }
    .hero-media img{ width:100%; height:auto; display:block; border-radius:12px; box-shadow:0 20px 40px rgba(0,0,0,0.08); }
    .hero-content{ position:absolute; left:6%; max-width:480px; color:var(--text); }
    .hero-content h1{ font-size:clamp(28px, 4vw, 48px); margin:0 0 8px 0; }
    .sub{ color:var(--muted); margin-bottom:16px; }
  </style>
</section>

{% schema %}
{
  "name": "Hero",
  "settings": [
    { "type": "image_picker", "id": "image", "label": "Background image" },
    { "type": "text", "id": "alt_text", "label": "Image alt text" },
    { "type": "text", "id": "heading", "label": "Heading", "default": "Luxury reimagined" },
    { "type": "text", "id": "subheading", "label": "Subheading", "default": "A modern collection for the discerning customer." },
    { "type": "text", "id": "cta_label", "label": "CTA label", "default": "Shop Now" },
    { "type": "url", "id": "cta_url", "label": "CTA URL", "default": "/collections/all" }
  ],
  "blocks": [],
  "preset": { "name": "Hero" }
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/slideshow.liquid" <<'EOF'
{% comment %}
Slideshow/banner with multiple slides and overlay text/cta.
Uses lazy loading and minimal animations.
{% endcomment %}

<section class="slideshow-section" aria-label="Slideshow">
  <div class="slideshow" data-slideshow>
    {% for block in section.blocks %}
      <div class="slide" data-slide>
        {% if block.settings.image %}
          <img src="{{ block.settings.image | image_url: width: 1800 }}" alt="{{ block.settings.alt }}" loading="lazy" />
        {% endif %}
        <div class="slide-overlay">
          <div class="container">
            <h2>{{ block.settings.title }}</h2>
            <p>{{ block.settings.text }}</p>
            {% if block.settings.button_label != blank %}
              <a class="btn btn-ghost" href="{{ block.settings.button_link }}">{{ block.settings.button_label }}</a>
            {% endif %}
          </div>
        </div>
      </div>
    {% endfor %}
  </div>

  <style>
    .slideshow{ position:relative; overflow:hidden; border-radius:12px; }
    .slide{ min-height:380px; position:relative; display:flex; align-items:center; transition:opacity .6s ease; }
    .slide img{ width:100%; height: auto; display:block; }
    .slide-overlay{ position:absolute; left:0; right:0; top:0; bottom:0; display:flex; align-items:center; }
    .slide-overlay h2{ font-size:2rem; color:#fff; }
    .btn-ghost{ background:rgba(255,255,255,0.12); color:#fff; padding:10px 16px; border-radius:6px;}
  </style>

  <script>
    // Simple slideshow for accessibility & small footprint
    (function(){
      const root = document.querySelector('[data-slideshow]');
      if(!root) return;
      const slides = Array.from(root.querySelectorAll('[data-slide]'));
      let idx = 0;
      slides.forEach((s,i)=> s.style.opacity = i===0? 1:0);
      setInterval(()=> {
        slides[idx].style.opacity = 0;
        idx = (idx+1) % slides.length;
        slides[idx].style.opacity = 1;
      }, 6000);
    })();
  </script>
</section>

{% schema %}
{
  "name": "Slideshow",
  "blocks": [
    {
      "type": "slide",
      "name": "Slide",
      "settings": [
        { "type": "image_picker", "id": "image", "label": "Image" },
        { "type": "text", "id": "alt", "label": "Alt text" },
        { "type": "text", "id": "title", "label": "Title" },
        { "type": "textarea", "id": "text", "label": "Text" },
        { "type": "text", "id": "button_label", "label": "Button label" },
        { "type": "url", "id": "button_link", "label": "Button link" }
      ]
    }
  ],
  "presets": [{ "name": "Homepage slideshow", "category": "Hero" }]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/featured-collections.liquid" <<'EOF'
{% comment %}
Show a selection of collections, usually used on homepage.
{% endcomment %}
<section class="featured-collections container" aria-label="Featured collections">
  <div class="grid">
    {% for block in section.blocks %}
      <div class="collection-card">
        <a href="{{ block.settings.collection }}">
          {% if block.settings.image %}
            <img src="{{ block.settings.image | image_url: width: 800 }}" alt="{{ block.settings.alt }}" loading="lazy">
          {% endif %}
          <div class="meta">
            <h3>{{ block.settings.title }}</h3>
            <p>{{ block.settings.subtitle }}</p>
          </div>
        </a>
      </div>
    {% endfor %}
  </div>

  <style>
    .featured-collections .grid{ display:grid; grid-template-columns:repeat(3,1fr); gap:18px; }
    .collection-card img{ width:100%; height:auto; display:block; border-radius:10px; }
    @media(max-width:900px){ .featured-collections .grid{ grid-template-columns:1fr; } }
  </style>
</section>

{% schema %}
{
  "name":"Featured collections",
  "blocks":[
    {
      "type":"collection",
      "name":"Collection",
      "settings":[
        { "type":"collection", "id":"collection", "label":"Collection" },
        { "type":"image_picker", "id":"image", "label":"Image" },
        { "type":"text", "id":"title", "label":"Title" },
        { "type":"text", "id":"subtitle", "label":"Subtitle" }
      ]
    }
  ],
  "presets":[ { "name":"Featured collections" } ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/product-grid.liquid" <<'EOF'
{% comment %}
Product grid used for collections, recommended lists, or carousels.
Supports quick view and wishlist via snippets.
{% endcomment %}
<section class="product-grid-section container">
  <h2>{{ section.settings.title }}</h2>
  <div class="product-grid">
    {% assign products_list = section.settings.collection != blank ? collections[section.settings.collection].products : section.settings.product_ids | split: ',' %}
    {% if section.settings.source == 'recommendations' and product %}
      {% assign products_list = product.recommendations %}
    {% endif %}

    {% for p in collections[section.settings.collection].products limit: section.settings.limit %}
      {% render 'product-card', product: p, show_wishlist: section.settings.enable_wishlist %}
    {% endfor %}
  </div>

  <style>
    .product-grid{ display:grid; grid-template-columns:repeat(4,1fr); gap:18px; }
    @media(max-width:1000px){ .product-grid{ grid-template-columns:repeat(2,1fr); } }
    @media(max-width:600px){ .product-grid{ grid-template-columns:1fr; } }
  </style>
</section>

{% schema %}
{
  "name":"Product grid",
  "settings":[
    { "type":"text", "id":"title", "label":"Title", "default":"Products" },
    { "type":"collection", "id":"collection", "label":"Source collection" },
    { "type":"number", "id":"limit", "label":"Number of items", "default":8 },
    { "type":"checkbox", "id":"enable_wishlist", "label":"Enable wishlist", "default": true },
    { "type":"select", "id":"source", "label":"Source", "options":[ { "value":"collection","label":"Collection" }, { "value":"recommendations","label":"Recommendations" } ], "default":"collection" }
  ],
  "presets":[ { "name":"Product grid" } ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/product-template.liquid" <<'EOF'
{% comment %}
Product page template section: images gallery, variant selector, add-to-cart, and metafield support.
{% endcomment %}

<section class="product-template container" itemscope itemtype="http://schema.org/Product">
  <div class="product-grid">
    <div class="gallery">
      {% for media in product.media %}
        <div class="media-item">
          {% if media.preview_image %}
            <img src="{{ media.preview_image | image_url: width:1200 }}" alt="{{ media.alt | escape }}" loading="lazy" data-zoom-src="{{ media.preview_image | image_url: width:2048 }}">
          {% endif %}
        </div>
      {% endfor %}
      <div class="thumbs">
        {% for media in product.media %}
          <button class="thumb" data-media-id="{{ media.id }}">
            <img src="{{ media.preview_image | image_url: width:200 }}" alt="">
          </button>
        {% endfor %}
      </div>
    </div>

    <div class="product-details">
      <h1 itemprop="name">{{ product.title }}</h1>
      <div class="vendor">{{ product.vendor }}</div>
      <div class="price" itemprop="offers" itemscope itemtype="http://schema.org/Offer">
        {% if product.compare_at_price_max > product.price %}
          <span class="price--compare">{{ product.compare_at_price | money }}</span>
        {% endif %}
        <span class="price--current">{{ product.price | money }}</span>
      </div>

      <form method="post" action="/cart/add" id="product-form-{{ product.id }}">
        {% if product.variants.size > 1 %}
          {% for option in product.options_with_values %}
            <label>{{ option.name }}
              <select name="options[{{ option.name }}]">
                {% for value in option.values %}
                  <option value="{{ value | escape }}">{{ value }}</option>
                {% endfor %}
              </select>
            </label>
          {% endfor %}
        {% endif %}
        <input type="hidden" name="id" value="{{ product.selected_or_first_available_variant.id }}">
        <button type="submit" class="btn btn-primary add-to-cart">Add to cart</button>
        <button type="button" class="btn btn-outline quick-view" data-product-id="{{ product.id }}">Quick view</button>
        {% render 'wishlist-button', product: product %}
      </form>

      <div class="product-description" itemprop="description">
        {{ product.description }}
      </div>

      <!-- Product metafields example -->
      {% if product.metafields.custom && product.metafields.custom.material %}
        <div class="product-meta">
          <strong>Material:</strong> {{ product.metafields.custom.material.value }}
        </div>
      {% endif %}
    </div>
  </div>

  <style>
    .product-grid{ display:grid; grid-template-columns: 1fr 420px; gap:32px; align-items:start; margin:48px 0; }
    .gallery img{ width:100%; display:block; border-radius:8px; }
    .thumbs{ display:flex; gap:8px; margin-top:10px; }
    .thumb img{ width:64px; height:64px; object-fit:cover; border-radius:6px; }
    @media(max-width:900px){ .product-grid{ grid-template-columns:1fr; } }
  </style>

  <script>
    // Simple gallery + zoom
    (function(){
      const gallery = document.querySelector('.product-template .gallery');
      if(!gallery) return;
      gallery.addEventListener('click', (e)=> {
        const img = e.target.closest('img');
        if(!img) return;
        const zoomSrc = img.dataset.zoomSrc;
        if(zoomSrc){
          // basic zoom: open in new tab for simplicity (can be replaced with fancy zoom)
          window.open(zoomSrc, '_blank');
        }
      });
      // Thumb switch
      const thumbs = document.querySelectorAll('.thumb');
      thumbs.forEach(t => t.addEventListener('click', ()=>{
        const id = t.dataset.mediaId;
        // Find media item and show it (lightweight)
        const mediaItems = document.querySelectorAll('.media-item');
        mediaItems.forEach(mi => mi.style.display = mi.querySelector('[data-media-id]') && mi.querySelector('[data-media-id]').value === id ? 'block' : 'none');
      }));
    })();
  </script>
</section>

{% schema %}
{
  "name": "Product template",
  "settings": [],
  "blocks": [],
  "presets":[ { "name":"Product" } ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/collection-template.liquid" <<'EOF'
{% comment %}
Collection page with filtering and sorting hooks.
This is a scaffold: implement storefront filtering with tag-based filters, or integrate an app.
{% endcomment %}
<section class="collection-template container">
  <div class="collection-header">
    <h1>{{ collection.title }}</h1>
    <p class="desc">{{ collection.description }}</p>
  </div>

  <div class="collection-controls">
    <div class="filters">
      <!-- Example filter by price ranges (requires backend or JS to filter) -->
      <label>Sort by:
        <select id="sort-by" name="sort_by">
          <option value="best-selling">Best selling</option>
          <option value="created-descending">Newest</option>
          <option value="price-ascending">Price, low to high</option>
          <option value="price-descending">Price, high to low</option>
        </select>
      </label>
    </div>
  </div>

  <div class="collection-products">
    {% paginate collection.products by 24 %}
      <div class="products-grid">
        {% for product in collection.products %}
          {% render 'product-card', product: product %}
        {% endfor %}
      </div>

      <div class="pagination">
        {% if paginate.previous %}
          <a href="{{ paginate.previous.url }}" class="btn">Previous</a>
        {% endif %}
        {% if paginate.next %}
          <a href="{{ paginate.next.url }}" class="btn">Next</a>
        {% endif %}
      </div>
    {% endpaginate %}
  </div>

  <style>
    .products-grid{ display:grid; grid-template-columns:repeat(4,1fr); gap:18px; }
    @media(max-width:1000px){ .products-grid{ grid-template-columns:repeat(2,1fr); } }
    @media(max-width:600px){ .products-grid{ grid-template-columns:1fr; } }
  </style>

  <script>
    // Lightweight client-side sorting hook (simple redirect to collection sort param)
    document.getElementById('sort-by')?.addEventListener('change',(e)=>{
      const val = e.target.value;
      const url = new URL(location.href);
      url.searchParams.set('sort_by', val);
      location.href = url.toString();
    });
  </script>
</section>

{% schema %}
{
  "name":"Collection template",
  "settings": [],
  "blocks": [],
  "presets":[ { "name":"Collection" } ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/testimonials.liquid" <<'EOF'
{% comment %} Simple testimonials slider {% endcomment %}
<section class="testimonials container">
  <h2>{{ section.settings.title }}</h2>
  <div class="slides">
    {% for block in section.blocks %}
      <blockquote class="testimony">
        <p>{{ block.settings.quote }}</p>
        <cite>{{ block.settings.author }}</cite>
      </blockquote>
    {% endfor %}
  </div>

  <style>
    .testimonials .slides{ display:flex; gap:18px; overflow:auto; padding:10px 0; }
    .testimony{ min-width:320px; background:rgba(0,0,0,0.03); padding:18px; border-radius:8px; }
  </style>
</section>

{% schema %}
{
  "name":"Testimonials",
  "settings":[ { "type":"text","id":"title","label":"Title","default":"What customers say" } ],
  "blocks":[
    { "type":"item","name":"Testimonial","settings":[ { "type":"textarea","id":"quote","label":"Quote" }, { "type":"text","id":"author","label":"Author" } ] }
  ],
  "presets":[{ "name":"Testimonials" }]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/newsletter.liquid" <<'EOF'
{% comment %} Newsletter form that posts to Shopify's built-in subscribe endpoint {% endcomment %}
<section class="newsletter-section">
  <form action="/contact#newsletter" method="post" class="newsletter-form">
    <input type="hidden" name="form_type" value="customer">
    <input type="hidden" name="contact[tags]" value="newsletter">
    <label>
      <span>{{ section.settings.heading }}</span>
      <input type="email" name="contact[email]" placeholder="{{ section.settings.placeholder }}" required>
    </label>
    <button type="submit" class="btn btn-primary">{{ section.settings.button_label }}</button>
  </form>

  <style>
    .newsletter-form{ display:flex; gap:8px; align-items:center; }
    .newsletter-form input[type="email"]{ padding:12px; border-radius:6px; border:1px solid rgba(0,0,0,0.06); }
  </style>
</section>

{% schema %}
{
  "name":"Newsletter",
  "settings":[
    { "type":"text","id":"heading","label":"Heading","default":"Join our newsletter" },
    { "type":"text","id":"placeholder","label":"Placeholder","default":"Email address" },
    { "type":"text","id":"button_label","label":"Button label","default":"Subscribe" }
  ],
  "presets":[ { "name":"Newsletter" } ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/instagram-feed.liquid" <<'EOF'
{% comment %}
Instagram feed integration scaffold. Real integration requires an app or API.
This section uses a collection or metafield for images as a fallback.
{% endcomment %}
<section class="instagram-feed container">
  <h3>{{ section.settings.title }}</h3>
  <div class="ig-grid">
    {% for block in section.blocks %}
      <a href="{{ block.settings.url }}" class="ig-item">
        <img src="{{ block.settings.image | image_url: width: 600 }}" alt="{{ block.settings.alt }}" loading="lazy">
      </a>
    {% endfor %}
  </div>
  <style>
    .ig-grid{ display:grid; grid-template-columns:repeat(6,1fr); gap:6px; }
    .ig-item img{ width:100%; height:100%; object-fit:cover; border-radius:6px; }
    @media(max-width:900px){ .ig-grid{ grid-template-columns:repeat(3,1fr); } }
  </style>
</section>

{% schema %}
{
  "name": "Instagram feed",
  "settings":[ { "type":"text","id":"title","label":"Title","default":"Instagram" } ],
  "blocks":[
    { "type":"media","name":"Image","settings":[ { "type":"image_picker","id":"image","label":"Image" }, { "type":"text","id":"alt","label":"Alt" }, { "type":"url","id":"url","label":"Link" } ] }
  ],
  "presets":[ { "name":"Instagram grid" } ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/about.liquid" <<'EOF'
{% comment %}
Customizable about page layout.
{% endcomment %}
<section class="about container">
  <div class="about-grid">
    <div class="media">
      {% if section.settings.image %}
        <img src="{{ section.settings.image | image_url: width:1000 }}" alt="{{ section.settings.alt }}">
      {% endif %}
    </div>
    <div class="content">
      <h1>{{ section.settings.heading }}</h1>
      <div class="text">{{ section.settings.text }}</div>
    </div>
  </div>

  <style>
    .about-grid{ display:grid; grid-template-columns:1fr 420px; gap:28px; align-items:center; }
    @media(max-width:900px){ .about-grid{ grid-template-columns:1fr; } }
  </style>
</section>

{% schema %}
{
  "name":"About",
  "settings":[
    { "type":"image_picker","id":"image","label":"Image" },
    { "type":"text","id":"alt","label":"Image alt" },
    { "type":"text","id":"heading","label":"Heading","default":"About us" },
    { "type":"richtext","id":"text","label":"Content","default":"Write about your brand here." }
  ],
  "presets":[ { "name":"About" } ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/contact-form.liquid" <<'EOF'
{% comment %} Contact form section using Shopify's contact form endpoint {% endcomment %}
<section class="contact container">
  <h1>{{ section.settings.heading }}</h1>

  <form method="post" action="/contact#contact_form" accept-charset="UTF-8" class="contact-form">
    <input type="hidden" name="form_type" value="contact" />
    <label>Name<input type="text" name="contact[name]" required></label>
    <label>Email<input type="email" name="contact[email]" required></label>
    <label>Message<textarea name="contact[body]" rows="6" required></textarea></label>
    <button type="submit" class="btn btn-primary">{{ section.settings.button_text }}</button>
  </form>

  <style>
    .contact-form label{ display:block; margin-bottom:10px; }
    .contact-form input, .contact-form textarea{ width:100%; padding:10px; border:1px solid rgba(0,0,0,0.06); border-radius:6px; }
  </style>
</section>

{% schema %}
{
  "name":"Contact",
  "settings":[
    { "type":"text","id":"heading","label":"Heading","default":"Contact us" },
    { "type":"text","id":"button_text","label":"Button text","default":"Send message" }
  ],
  "presets":[ { "name":"Contact form" } ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/blog-list.liquid" <<'EOF'
{% comment %} Blog listing with featured images and author info {% endcomment %}
<section class="blog-list container">
  <h1>{{ blog.title }}</h1>
  <div class="posts-grid">
    {% for article in blog.articles %}
      <article class="post-card">
        {% if article.image %}
          <a href="{{ article.url }}"><img src="{{ article.image | image_url: width:800 }}" alt="{{ article.title }}" loading="lazy"></a>
        {% endif %}
        <div class="meta">
          <a href="{{ article.url }}"><h3>{{ article.title }}</h3></a>
          <p class="byline">By {{ article.author }} · {{ article.published_at | date: "%b %-d, %Y" }}</p>
          <p>{{ article.excerpt | strip_html | truncate: 140 }}</p>
        </div>
      </article>
    {% endfor %}
  </div>

  <style>
    .posts-grid{ display:grid; grid-template-columns:repeat(3,1fr); gap:18px; }
    @media(max-width:1000px){ .posts-grid{ grid-template-columns:repeat(2,1fr); } }
    @media(max-width:600px){ .posts-grid{ grid-template-columns:1fr; } }
  </style>
</section>

{% schema %}
{
  "name":"Blog list",
  "settings":[],
  "presets":[{"name":"Blog list"}]
}
{% endschema %}
EOF

# Account related sections
cat > "$OUTDIR/sections/account.liquid" <<'EOF'
{% comment %}
Customer account overview section.
Shows greeting, basic account links, and quick actions.
This section is intended for customers/account.json
{% endcomment %}

<section class="customer-account container" aria-label="Account overview">
  {% if customer %}
    <header class="account-hero">
      <h1>Welcome back, {{ customer.first_name | default: customer.email }}</h1>
      <p class="muted">Manage your orders, addresses, and account details.</p>
    </header>

    <div class="account-actions">
      <a href="/account" class="btn">Account details</a>
      <a href="/account/orders" class="btn">Orders</a>
      <a href="/account/addresses" class="btn">Addresses</a>
      <form method="post" action="/account/logout" style="display:inline;">
        <button type="submit" class="btn btn-outline">Log out</button>
      </form>
    </div>

    <style>
      .account-hero{ margin:22px 0; }
      .account-actions{ display:flex; gap:10px; flex-wrap:wrap; }
    </style>

  {% else %}
    <div class="account-empty">
      <p>Please <a href="/account/login">sign in</a> or <a href="/account/register">create an account</a> to manage your orders.</p>
    </div>
  {% endif %}
</section>

{% schema %}
{
  "name":"Account overview",
  "settings":[],
  "presets":[{"name":"Account overview"}]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/account-login.liquid" <<'EOF'
{% comment %}
Login / Register / Reset password section.
The section uses "mode" setting to switch between views:
- mode = 'login' -> show login form
- mode = 'register' -> show registration form
- mode = 'reset' -> show password reset form
This allows reuse across multiple templates.
{% endcomment %}

<section class="account-auth container" aria-label="Customer authentication">
  {% assign mode = section.settings.mode | default: 'login' %}
  {% if mode == 'login' %}
    <h1>Sign in</h1>
    <form method="post" action="/account/login" id="customer_login" accept-charset="UTF-8">
      <label>Email<input type="email" name="customer[email]" required></label>
      <label>Password<input type="password" name="customer[password]" required></label>
      <button type="submit" class="btn btn-primary">{{ 'general.add_to_cart' | t: default: 'Sign in' }}</button>
      <p><a href="/account/register">Create an account</a> · <a href="/account/recover">Forgot password?</a></p>
    </form>

  {% elsif mode == 'register' %}
    <h1>Create account</h1>
    <form method="post" action="/account" id="create_customer" accept-charset="UTF-8">
      <input type="hidden" name="form_type" value="create_customer">
      <label>First name<input type="text" name="customer[first_name]"></label>
      <label>Last name<input type="text" name="customer[last_name]"></label>
      <label>Email<input type="email" name="customer[email]" required></label>
      <label>Password<input type="password" name="customer[password]" required></label>
      <button type="submit" class="btn btn-primary">Create account</button>
      <p>Already have an account? <a href="/account/login">Sign in</a></p>
    </form>

  {% elsif mode == 'reset' %}
    <h1>Reset your password</h1>
    <p>Enter your email and we will send instructions to reset your password.</p>
    <form method="post" action="/account/recover" accept-charset="UTF-8">
      <label>Email<input type="email" name="email" required></label>
      <button type="submit" class="btn btn-primary">Send reset instructions</button>
      <p><a href="/account/login">Back to sign in</a></p>
    </form>
  {% endif %}

  <style>
    .account-auth form{ max-width:520px; margin-top:12px; display:flex; flex-direction:column; gap:10px; }
    .account-auth input{ padding:10px; border-radius:6px; border:1px solid rgba(0,0,0,0.06); }
  </style>
</section>

{% schema %}
{
  "name":"Account auth",
  "settings":[
    { "type":"select", "id":"mode", "label":"Mode", "options":[ { "value":"login","label":"Login" }, { "value":"register","label":"Register" }, { "value":"reset","label":"Reset password" } ], "default":"login" }
  ],
  "presets":[ { "name":"Login / Register" } ]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/account-orders.liquid" <<'EOF'
{% comment %}
Account orders list. Uses store's Orders API-provided 'orders' object in customer pages.
If orders require app integration, replace with app-provided data.
{% endcomment %}

<section class="account-orders container" aria-label="Your orders">
  <h2>Your orders</h2>

  {% if customer.orders_count > 0 %}
    <div class="orders-list">
      {% for order in customer.orders %}
        {% render 'order-card', order: order %}
      {% endfor %}
    </div>
  {% else %}
    <p class="muted">You have no orders yet. Start shopping and your orders will appear here.</p>
  {% endif %}

  <style>
    .orders-list{ display:flex; flex-direction:column; gap:12px; margin-top:12px; }
  </style>
</section>

{% schema %}
{
  "name":"Account orders",
  "settings":[],
  "presets":[{"name":"Orders"}]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/account-addresses.liquid" <<'EOF'
{% comment %}
Addresses manager: lists addresses and provides add/edit links.
For full CRUD you'd integrate with an app or add forms that POST to account endpoints.
{% endcomment %}

<section class="account-addresses container" aria-label="Your addresses">
  <h2>Addresses</h2>

  {% if customer %}
    {% assign addr_list = customer.addresses %}
    {% if addr_list != empty %}
      <ul class="addresses">
        {% for addr in addr_list %}
          <li class="address-card">
            <p>
              {{ addr.name }}<br>
              {{ addr.address1 }}{% if addr.address2 %}, {{ addr.address2 }}{% endif %}<br>
              {{ addr.city }}, {{ addr.province }} {{ addr.zip }}<br>
              {{ addr.country }}<br>
              <a href="/account/addresses/{{ addr.id }}">Edit</a>
            </p>
          </li>
        {% endfor %}
      </ul>
    {% else %}
      <p class="muted">No saved addresses. <a href="/account/addresses">Add an address</a></p>
    {% endif %}
  {% endif %}

  <style>
    .addresses{ display:grid; grid-template-columns:repeat(2,1fr); gap:12px; }
    @media(max-width:900px){ .addresses{ grid-template-columns:1fr; } }
    .address-card{ padding:12px; border:1px solid rgba(0,0,0,0.04); border-radius:8px; }
  </style>
</section>

{% schema %}
{
  "name":"Account addresses",
  "settings":[],
  "presets":[{"name":"Addresses"}]
}
{% endschema %}
EOF

cat > "$OUTDIR/sections/product-quick.liquid" <<'EOF'
{% comment %}
A compact product view tailored for quick view modals.
This section is intended for product.quick.liquid (fetched into the quick-view modal).
It includes product thumbnail, title, price, variant selector (minimal), and add-to-cart button suitable for modal usage.
{% endcomment %}

{%- if product -%}
<div class="product-quick" itemscope itemtype="http://schema.org/Product">
  <div class="quick-grid">
    <div class="quick-media">
      {% assign m = product.featured_image | default: product.images.first %}
      {% if m %}
        <img src="{{ m | image_url: width:800 }}" alt="{{ product.title }}" loading="lazy">
      {% endif %}
    </div>

    <div class="quick-info">
      <h2 itemprop="name">{{ product.title }}</h2>
      <div class="vendor">{{ product.vendor }}</div>
      <div class="price">
        {% if product.compare_at_price_max > product.price %}
          <span class="compare">{{ product.compare_at_price | money }}</span>
        {% endif %}
        <span class="current">{{ product.price | money }}</span>
      </div>

      <form action="/cart/add" method="post" class="quick-add">
        {% if product.variants.size > 1 %}
          {% for option in product.options_with_values %}
            <label>{{ option.name }}
              <select name="options[{{ option.name }}]">
                {% for val in option.values %}
                  <option value="{{ val | escape }}">{{ val }}</option>
                {% endfor %}
              </select>
            </label>
          {% endfor %}
        {% endif %}
        <input type="hidden" name="id" value="{{ product.selected_or_first_available_variant.id }}">
        <button class="btn btn-primary" type="submit">Add to cart</button>
      </form>

      <p class="desc">{{ product.description | strip_html | truncate: 240 }}</p>
    </div>
  </div>

  <style>
    .product-quick .quick-grid{ display:grid; grid-template-columns:1fr 1fr; gap:18px; align-items:start; }
    @media(max-width:800px){ .product-quick .quick-grid{ grid-template-columns:1fr; } }
    .quick-media img{ border-radius:8px; }
  </style>
</div>
{%- else -%}
  <p class="muted">Product not found.</p>
{%- endif -%}
EOF

cat > "$OUTDIR/sections/app-blocks.liquid" <<'EOF'
{% comment %}
App blocks scaffold section.
This section exposes a block area where apps can inject dynamic app blocks.
Merchants can add "App blocks" to pages via the editor when an app provides blocks for this section.
{% endcomment %}

<section class="app-blocks container" aria-label="App blocks">
  <div class="app-block-area">
    {% for block in section.blocks %}
      {% if block.type contains 'app' %}
        <div class="app-block" id="app-block-{{ block.id }}">
          {{ block.content }}
        </div>
      {% else %}
        <!-- placeholder for non-app blocks -->
        <div class="editor-block">{{ block.settings.title }}</div>
      {% endif %}
    {% endfor %}
  </div>

  <style>
    .app-blocks .app-block-area{ display:flex; gap:12px; flex-wrap:wrap; }
    .app-blocks .app-block{ width:100%; }
  </style>
</section>

{% schema %}
{
  "name": "App blocks area",
  "settings": [],
  "blocks": [
    {
      "type": "app",
      "name": "App block",
      "settings": []
    },
    {
      "type": "static",
      "name": "Static block",
      "settings": [
        { "type": "text", "id": "title", "label": "Title" },
        { "type": "textarea", "id": "content", "label": "Content" }
      ]
    }
  ],
  "presets": [
    { "name": "App blocks area" }
  ]
}
{% endschema %}
EOF

# --------------------------
# snippets/*.liquid
# --------------------------
cat > "$OUTDIR/snippets/product-card.liquid" <<'EOF'
{% comment %}
Product card snippet used across the theme.
Includes hover image, quick view button, price, and wishlist toggle.
{% endcomment %}
<article class="product-card" itemscope itemtype="http://schema.org/Product">
  <a href="{{ product.url }}" class="product-card-link">
    <div class="media">
      {% assign pimg = product.featured_image | default: product.images.first %}
      {% if pimg %}
        <img src="{{ pimg | image_url: width:800 }}" alt="{{ product.title }}" loading="lazy">
      {% endif %}
    </div>

    <div class="info">
      <h3 itemprop="name">{{ product.title }}</h3>
      <div class="price">
        {% if product.compare_at_price_max > product.price %}
          <span class="compare">{{ product.compare_at_price | money }}</span>
        {% endif %}
        <span class="current">{{ product.price | money }}</span>
      </div>
    </div>
  </a>

  <div class="card-actions">
    <button class="btn-quick-view" data-product-id="{{ product.id }}">Quick view</button>
    {% if show_wishlist %}
      {% render 'wishlist-button', product: product %}
    {% endif %}
  </div>
</article>

<style>
  .product-card{ background:var(--bg); border-radius:10px; padding:12px; display:flex; flex-direction:column; gap:12px; }
  .product-card .media img{ width:100%; border-radius:8px; object-fit:cover; }
  .card-actions{ display:flex; gap:8px; }
</style>
EOF

cat > "$OUTDIR/snippets/quick-view.liquid" <<'EOF'
{% comment %} Minimal quick view modal that fetches product HTML via Shopify's product template endpoint. Extend as needed. {% endcomment %}
<div id="quick-view-modal" class="quick-view-modal" hidden aria-hidden="true" role="dialog">
  <div class="quick-view-inner">
    <button class="quick-view-close" data-action="close">×</button>
    <div id="quick-view-content"></div>
  </div>

  <style>
    .quick-view-modal{ position:fixed; inset:0; display:flex; align-items:center; justify-content:center; background:rgba(2,2,2,0.6); z-index:120; }
    .quick-view-inner{ width:min(1000px,95%); background:var(--bg); border-radius:8px; padding:20px; position:relative; }
    .quick-view-close{ position:absolute; right:12px; top:12px; border:none; background:transparent; font-size:22px; cursor:pointer; }
  </style>
</div>

<script>
  // Quick view fetcher: lightweight fetch to product URL with view=quick
  document.addEventListener('click', async (e) => {
    const btn = e.target.closest('[data-product-id]');
    if(!btn) return;
    const id = btn.dataset.productId;
    const modal = document.getElementById('quick-view-modal');
    const content = document.getElementById('quick-view-content');
    try {
      const resp = await fetch(`/products/${id}?view=quick`);
      if(!resp.ok) throw new Error('Failed to fetch');
      content.innerHTML = await resp.text();
      modal.hidden = false;
      modal.setAttribute('aria-hidden', 'false');
    } catch(err){
      console.error(err);
    }
  });

  document.addEventListener('click', (e)=>{
    if(e.target.matches('.quick-view-close') || e.target.matches('#quick-view-modal')) {
      const modal = document.getElementById('quick-view-modal');
      modal.hidden = true;
      modal.setAttribute('aria-hidden','true');
      document.getElementById('quick-view-content').innerHTML = '';
    }
  });
</script>
EOF

cat > "$OUTDIR/snippets/wishlist-button.liquid" <<'EOF'
{% comment %} Minimal wishlist toggle that uses localStorage. Replace with app integration for persistence. {% endcomment %}
<button class="wishlist-toggle" aria-pressed="false" data-product-handle="{{ product.handle }}">
  ♥
</button>

<script>
  (function(){
    const btns = document.querySelectorAll('.wishlist-toggle');
    btns.forEach(btn => {
      const handle = btn.dataset.productHandle;
      const list = JSON.parse(localStorage.getItem('har-wishlist') || '[]');
      if(list.includes(handle)) btn.setAttribute('aria-pressed','true');
      btn.addEventListener('click', ()=>{
        let list = JSON.parse(localStorage.getItem('har-wishlist') || '[]');
        if(list.includes(handle)){
          list = list.filter(h => h !== handle);
          btn.setAttribute('aria-pressed','false');
        } else {
          list.push(handle);
          btn.setAttribute('aria-pressed','true');
        }
        localStorage.setItem('har-wishlist', JSON.stringify(list));
      });
    });
  })();
</script>
EOF

cat > "$OUTDIR/snippets/icon-search.liquid" <<'EOF'
<svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true">
  <path d="M21 21l-4.35-4.35" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"></path>
  <circle cx="11" cy="11" r="6" stroke="currentColor" stroke-width="1.6" fill="none"></circle>
</svg>
EOF

cat > "$OUTDIR/snippets/icon-cart.liquid" <<'EOF'
<svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true">
  <path d="M6 6h15l-1.5 9h-12z" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="10" cy="20" r="1" fill="currentColor"></circle>
  <circle cx="18" cy="20" r="1" fill="currentColor"></circle>
</svg>
EOF

cat > "$OUTDIR/snippets/currency-selector.liquid" <<'EOF'
<form method="post" action="/cart" class="currency-form" aria-label="Currency selector">
  <select name="currency" onchange="this.form.submit()">
    {% for currency in shop.enabled_currencies %}
      <option value="{{ currency }}" {% if currency == shop.currency %}selected{% endif %}>{{ currency }}</option>
    {% endfor %}
  </select>
</form>
EOF

cat > "$OUTDIR/snippets/social-icons.liquid" <<'EOF'
<ul class="social-icons">
  {% if shop.social_accounts.facebook %}<li><a href="{{ shop.social_accounts.facebook }}" rel="noopener">Facebook</a></li>{% endif %}
  {% if shop.social_accounts.instagram %}<li><a href="{{ shop.social_accounts.instagram }}" rel="noopener">Instagram</a></li>{% endif %}
  {% if shop.social_accounts.twitter %}<li><a href="{{ shop.social_accounts.twitter }}" rel="noopener">Twitter</a></li>{% endif %}
</ul>
EOF

cat > "$OUTDIR/snippets/lazy-image.liquid" <<'EOF'
{% comment %} Lazy image snippet using data-src for vendor-lazyload.js {% endcomment %}
<img class="lazy" data-src="{{ image | image_url: width: width }}" alt="{{ alt }}" src="{{ placeholder | default: 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==' }}">
EOF

cat > "$OUTDIR/snippets/order-card.liquid" <<'EOF'
{% comment %}
Order card snippet for rendering a single order in account orders list.
Use within account-orders section where customer.orders is available.
{% endcomment %}
<article class="order-card">
  <header class="order-meta">
    <div>Order #{{ order.name }}</div>
    <div class="muted">{{ order.created_at | date: "%b %-d, %Y" }}</div>
  </header>

  <div class="order-body">
    <ul>
      {% for line in order.line_items limit:3 %}
        <li>{{ line.quantity }} × {{ line.title }}</li>
      {% endfor %}
      {% if order.line_items.size > 3 %}
        <li class="muted">and {{ order.line_items.size | minus: 3 }} more</li>
      {% endif %}
    </ul>
  </div>

  <footer class="order-actions">
    <a href="/account/orders/{{ order.id }}" class="btn btn-outline">View details</a>
  </footer>

  <style>
    .order-card{ padding:12px; border:1px solid rgba(0,0,0,0.04); border-radius:8px; }
    .order-meta{ display:flex; justify-content:space-between; margin-bottom:8px; }
  </style>
EOF

cat > "$OUTDIR/snippets/address-form.liquid" <<'EOF'
{% comment %}
Address form snippet for adding/editing addresses.
This is a scaffold; to persist addresses merchant may use /account/addresses endpoint or an app.
{% endcomment %}
<form method="post" action="{{ form_action | default: '/account/addresses' }}" class="address-form">
  <input type="hidden" name="address[id]" value="{{ address.id }}">
  <label>Full name<input type="text" name="address[name]" value="{{ address.name }}"></label>
  <label>Address 1<input type="text" name="address[address1]" value="{{ address.address1 }}"></label>
  <label>Address 2<input type="text" name="address[address2]" value="{{ address.address2 }}"></label>
  <label>City<input type="text" name="address[city]" value="{{ address.city }}"></label>
  <label>Province<input type="text" name="address[province]" value="{{ address.province }}"></label>
  <label>Postal / ZIP<input type="text" name="address[zip]" value="{{ address.zip }}"></label>
  <label>Country<input type="text" name="address[country]" value="{{ address.country }}"></label>
  <button type="submit" class="btn btn-primary">Save address</button>
</form>

<style>
  .address-form{ display:flex; flex-direction:column; gap:8px; max-width:600px; }
  .address-form input{ padding:10px; border-radius:6px; border:1px solid rgba(0,0,0,0.06); }
</style>
EOF

# --------------------------
# assets/*
# --------------------------
cat > "$OUTDIR/assets/main.css" <<'EOF'
/* HAR Impulse - core styles (concise, override in theme editor) */
/* CSS variables for quick theming */
:root{
  --brand:#111;
  --accent:#b08b59;
  --bg:#ffffff;
  --text:#111111;
  --muted:#6b6b6b;
  --gap:18px;
}

/* Basic layout */
.container{ max-width:1200px; margin:0 auto; padding:0 18px; }
.btn{ display:inline-block; padding:10px 14px; border-radius:8px; text-decoration:none; }
.btn-primary{ background:var(--brand); color:#fff; }
.btn-outline{ border:1px solid rgba(0,0,0,0.06); color:var(--text); background:transparent; }

a{ color:var(--brand); text-decoration:none; }
img{ max-width:100%; height:auto; display:block; }

/* Accessibility focus outlines */
:focus{ outline:3px solid rgba(176,139,89,0.25); outline-offset:2px; }

/* Small utilities */
.flex{ display:flex; gap:var(--gap); }
.grid{ display:grid; gap:var(--gap); }

/* Lightweight animations */
.fade-in{ animation:fadeIn .45s ease both; }
@keyframes fadeIn { from { opacity:0; transform:translateY(6px);} to { opacity:1; transform:none; } }

/* Responsive helpers */
@media (prefers-reduced-motion: reduce) {
  .fade-in{ animation:none;}
}

/* Improve image loading */
img[loading="lazy"]{ opacity:0; transform:translateY(6px); transition:opacity .35s ease, transform .35s ease; }
img[loading="lazy"].loaded{ opacity:1; transform:none; }

/* Dark theme (switch via [data-theme="dark"]) */
[data-theme="dark"]{
  --bg:#0b0b0b; --text:#f7f7f7; --muted:#9b9b9b; --brand:#e8d9c5;
}
body{ background:var(--bg); color:var(--text); }
EOF

cat > "$OUTDIR/assets/theme.js" <<'EOF'
// HAR Impulse - minimal modern JS (ES6)
// Handles: lazy loading integration, search drawer, sticky header animation, quick view triggers.
// Keep small and modular so it's easy to extend.

import LazyLoad from './vendor-lazyload.js';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize lazy loader
  if (window.LazyLoad) {
    new LazyLoad({
      elements_selector: ".lazy, img[loading='lazy']",
      threshold: 300,
      callback_loaded: el => el.classList.add('loaded')
    });
  }

  // Search drawer toggle
  document.querySelectorAll('[data-action="open-search"]').forEach(btn => {
    btn.addEventListener('click', () => {
      const drawer = document.querySelector('[data-drawer="search"]');
      if(drawer) {
        drawer.hidden = !drawer.hidden;
      }
    });
  });

  // Sticky header class for small shadow while scrolling
  const header = document.querySelector('.site-header');
  if(header && header.dataset.sticky === "true") {
    let lastScroll = 0;
    window.addEventListener('scroll', () => {
      const sc = window.scrollY;
      if(sc > 30) header.classList.add('is-scrolled'); else header.classList.remove('is-scrolled');
      lastScroll = sc;
    });
  }

  // Quick view delegation (buttons are wired via snippet JS too)
  document.addEventListener('click', (e) => {
    const btn = e.target.closest('.btn-quick-view');
    if(!btn) return;
    const prodId = btn.dataset.productId;
    // Could open quick view; the snippet attaches fetch behaviour
  });

  // Simple accessibility: close drawer on Esc
  document.addEventListener('keydown', (e) => {
    if(e.key === 'Escape') {
      document.querySelectorAll('[data-drawer="search"]').forEach(d => d.hidden = true);
      document.querySelectorAll('#quick-view-modal').forEach(m => { m.hidden = true; m.setAttribute('aria-hidden','true'); });
    }
  });
});
EOF

cat > "$OUTDIR/assets/vendor-lazyload.js" <<'EOF'
/* Minimal lazyload implementation (tiny, dependency-free) */
(function(global){
  function LazyLoad(options){
    this.options = Object.assign({ elements_selector: '.lazy', threshold:300 }, options || {});
    this._observer = null;
    this._init();
  }
  LazyLoad.prototype._init = function(){
    const supportsIntersection = 'IntersectionObserver' in window;
    this.elements = Array.prototype.slice.call(document.querySelectorAll(this.options.elements_selector));
    if(supportsIntersection){
      this._observer = new IntersectionObserver(this._onIntersection.bind(this), {
        rootMargin: this.options.threshold + 'px'
      });
      this.elements.forEach(el => this._observer.observe(el));
    } else {
      // fallback: load all
      this.loadAll();
    }
  };
  LazyLoad.prototype._onIntersection = function(entries){
    entries.forEach(entry => {
      if(entry.isIntersecting){
        this._observer.unobserve(entry.target);
        this._loadElement(entry.target);
      }
    });
  };
  LazyLoad.prototype._loadElement = function(el){
    if(el.tagName === 'IMG' || el.tagName === 'IFRAME'){
      const src = el.dataset.src || el.getAttribute('data-src');
      if(src) el.src = src;
      const srcset = el.dataset.srcset || el.getAttribute('data-srcset');
      if(srcset) el.srcset = srcset;
      el.addEventListener('load', ()=> {
        el.classList.add('loaded');
        if(typeof this.options.callback_loaded === 'function') this.options.callback_loaded(el);
      });
    } else {
      const bg = el.dataset.bg;
      if(bg) el.style.backgroundImage = 'url('+bg+')';
    }
  };
  global.LazyLoad = LazyLoad;
})(window);
EOF

cat > "$OUTDIR/assets/icons.svg" <<'EOF'
<!-- Collection of inline icons to reference via <svg><use xlink:href="#icon-name"></use></svg> -->
<svg xmlns="http://www.w3.org/2000/svg" style="display:none;">
  <symbol id="logo-mark" viewBox="0 0 100 100">
    <circle cx="50" cy="50" r="45" fill="#b08b59"></circle>
  </symbol>
</svg>
EOF

# placeholder image created from base64 1x1 GIF
cat > "$OUTDIR/assets/placeholder.jpg" <<'EOF'
R0lGODlhAQABAIAAAAAAAP///
EOF
# decode placeholder to binary file
# Create an actual 1x1 pixel gif (base64)
printf '%s' 'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7' | base64 -d > "$OUTDIR/assets/placeholder.jpg"

# --------------------------
# config & locales
# --------------------------
cat > "$OUTDIR/config/settings_schema.json" <<'EOF'
[
  {
    "name": "General",
    "settings": [
      { "type": "text", "id": "default_theme", "label": "Default theme mode (light/dark)", "default": "light" },
      { "type": "color", "id": "theme_color", "label": "Primary theme color", "default": "#111111" },
      { "type": "image_picker", "id": "logo", "label": "Store logo" }
    ]
  },
  {
    "name": "Header",
    "settings": [
      { "type": "link_list", "id": "main_menu", "label": "Main navigation" }
    ]
  },
  {
    "name": "Footer",
    "settings": [
      { "type": "text", "id": "footer_copyright", "label": "Footer copyright" }
    ]
  }
]
EOF

cat > "$OUTDIR/locales/en.default.json" <<'EOF'
{
  "general": {
    "add_to_cart": "Add to cart",
    "view_cart": "View cart",
    "checkout": "Checkout",
    "search": "Search",
    "newsletter_heading": "Join our newsletter"
  },
  "header": {
    "menu": "Menu"
  },
  "errors": {
    "required": "This field is required."
  }
}
EOF

# --------------------------
# All files written; create ZIP
# --------------------------
echo "Creating ZIP archive $ZIPNAME ..."
if command -v zip >/dev/null 2>&1; then
  (cd "$OUTDIR" && zip -r "../$ZIPNAME" .) >/dev/null
elif command -v python3 >/dev/null 2>&1; then
  python3 - <<PYZ
import os, zipfile
root = os.path.join(os.getcwd(), "$OUTDIR")
zf = zipfile.ZipFile("$ZIPNAME", "w", zipfile.ZIP_DEFLATED)
for base, dirs, files in os.walk(root):
    for f in files:
        full = os.path.join(base,f)
        arcname = os.path.relpath(full, root)
        zf.write(full, arcname)
zf.close()
PYZ
else
  echo "Error: neither zip nor python3 is available to create the archive."
  exit 1
fi

echo "Created $ZIPNAME in $(pwd). You can now upload this ZIP via GitHub web UI (Add file > Upload files) into the repository or extract it locally."