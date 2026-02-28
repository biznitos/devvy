# Devvy — Curator Website Development Environment

Devvy is a lightweight Elixir/Phoenix app that replicates the Curator CMS rendering pipeline with file-based templates and mock JSON data.

## Active Site

At the start of each session, check `sites/` for existing sites and present a menu using the AskUserQuestion tool:
- First option: "Create a new site" (then run the /newsite workflow)
- Remaining options: Up to 10 most recently modified sites (use `ls -lt sites/` to sort), showing the site name
Once a site is selected, remember it for the rest of the conversation.

## Quick Start

```bash
mix deps.get
mix phx.server
# Open http://localhost:3000/?site=example
```

## Project Structure

- `lib/liquid/` — Custom Liquid tags and filters (ported from curator-web)
- `lib/devvy/` — Core modules: Renderer, TemplateStore, MockData
- `lib/devvy_web/` — Phoenix controller and router
- `sites/` — One directory per site project
- `sites/{name}/site.json` — Site configuration
- `sites/{name}/templates/` — Liquid templates
- `sites/{name}/data/` — Mock JSON data (posts.json, users.json, leads.json)

## Site Generation Rules

When generating a new site with `/newsite`:

### Required Files
- `site.json` — Site config with all fields populated
- `templates/layout.liquid` — Main layout with Tailwind CDN, nav, footer
- `templates/homepage.liquid` — Hero, services grid, blog preview, contact CTA
- `templates/services.liquid` — Service listing page
- `templates/category_single.liquid` — Individual service page (type "category")
- `templates/blog.liquid` — Blog listing
- `templates/blog_single.liquid` — Individual blog post
- `templates/contact.liquid` — Contact page with form
- `templates/thank-you.liquid` — Form submission confirmation
- `templates/login.liquid` — Login page
- `templates/user.liquid` — User profile page
- `templates/page_single.liquid` — Generic content page
- `templates/content_single.liquid` — Content page (fallback)
- `templates/404.liquid` — Not found page
- `templates/_seo.liquid` — SEO partial (OG, Twitter, JSON-LD, geo meta)
- `templates/_contact.liquid` — Contact form partial
- `templates/_subscribe.liquid` — Subscribe form partial
- `templates/_quote.liquid` — Quote request form partial
- `templates/_login.liquid` — Login form partial
- `data/posts.json` — All posts (services as type "category", blog posts, pages)
- `data/users.json` — Team members
- `data/leads.json` — Sample leads

### site.json Required Fields
```json
{
  "id": 1,
  "name": "Business Name",
  "cname": "business-domain.com",
  "description": "One-line description with city + service keywords",
  "email": "contact@domain.com",
  "phone": "+1-555-0123",
  "address": "123 Main St",
  "city": "City Name",
  "region": "State/Province",
  "country_code": "US",
  "postal_code": "12345",
  "locale": "en",
  "logo": "https://placehold.co/300x100?text=Logo",
  "settings": {
    "geo": { "lat": "0.0", "lng": "0.0" },
    "social": { "facebook": "...", "instagram": "..." }
  }
}
```

### Post Schema (posts.json)
Each post must have:
- `id` — unique integer
- `zid` — unique string identifier
- `type` — "category" (services), "blog", "page"
- `title` — keyword-rich, includes city where natural
- `description` — 150-160 chars, includes city + service + CTA
- `permalink` — clean URL: `/services/{slug}`, `/blog/{slug}`, `/{slug}`
- `content` — HTML with proper heading hierarchy (h2, h3, h4)
- `cover_image` — placeholder URL like `https://placehold.co/800x600?text=Topic`
- `pubdate` — ISO 8601 datetime
- `tags` — comma-separated string
- `created_by` — user ID integer

### SEO Requirements (Non-Negotiable)

Every generated site must include:

1. **Permalink structure**: `/services/{slug}` for services, `/blog/{slug}` for blog, `/{slug}` for pages
2. **Meta tags**: Unique title (50-60 chars) and description (150-160 chars) per page
3. **Open Graph + Twitter Cards**: Via `_seo.liquid` partial
4. **JSON-LD**: LocalBusiness (homepage), Service (category posts), Article (blog posts), BreadcrumbList (inner pages)
5. **Geo meta tags**: region, placename, position, ICBM
6. **NAP consistency**: Name, Address, Phone identical in footer, contact page, and JSON-LD
7. **HTML semantics**: Single h1 per page, proper heading hierarchy, semantic elements
8. **Internal linking**: Services cross-link, blog references services, homepage links key pages

### Content Voice & Style Rules

- **Second-person voice only.** Use "you/your/yours" instead of "we/us/our." Rarely, if ever, use first person. Example: "Your old furniture picked up fast" not "We pick up your old furniture fast."
- **No em dashes (—) in content.** Never use em dashes in visible text. Use a comma, period, or reword instead. Regular hyphens in compound words (same-day, high-rise, eco-friendly, etc.) are fine.

### Template Conventions

- Layout includes `{{body}}` placeholder where page content is injected
- Layout includes `{% partial "_seo" %}` in `<head>`
- Use Tailwind CSS classes via CDN (`<script src="https://cdn.tailwindcss.com"></script>`)
- Forms submit to `/api/lead/v1` (contact/quote) or `/api/auth` (login)
- Forms include `return_url` and `failure_url` hidden fields
- **Partial naming**: Use underscores only, never hyphens. Example: `_cta_bottom.liquid` not `_cta-bottom.liquid`

### Available Liquid Tags
- `{% posts type:"blog", limit:5, name:"articles" %}` — Query posts from mock data
- `{% partial "_seo" %}` — Include a partial template
- `{% users role:"admin", limit:5 %}` — Query users
- `{% leads type:"contact" %}` — Query leads
- `{% types type:"category" %}` — Get type/subtype counts
- `{% runner "permalink" %}` — Stub (dev only)

### Available Liquid Filters
- `resize: '400x300'` — Generates placeholder image URL
- `money: "USD"` — Currency formatting
- `strip_html` — Remove HTML tags
- `proper` — Title Case
- `singular` — Singularize word
- `to_url` — Parameterize to URL-safe string
- `markdown` — Render Markdown to HTML
- `prose` / `prose_small` / `tailwind_prose` — Wrap in prose div
- `time_ago_in_words` — Relative time string
- `html_encode` / `html_decode` — HTML entity encoding
- `json_encode` — JSON serialization
- `domain` — Extract domain from URL
- `enum: "join", ","` — Dynamic Enum calls
- Standard Liquid filters: `truncate`, `date`, `upcase`, `downcase`, `default`, etc.

### Iteration Patterns

When modifying templates:
- Edit `.liquid` files directly — browser auto-refreshes
- Modify `data/posts.json` to add/change content
- Templates resolve by type: posts with `type: "category"` use `category_single.liquid`
- Partials start with underscore: `_seo.liquid`, `_contact.liquid`

### Preview URL
After generating: `http://localhost:3000/?site={sitename}`

Switch between sites: visit `http://localhost:3000/devvy` for the dashboard.
