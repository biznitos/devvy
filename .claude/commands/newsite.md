Create a new Curator site in the devvy development environment.

Site name: $ARGUMENTS

Ask the user for:
1. Business name (display name)
2. Business type / industry
3. Location (city, region, country)
4. One-line description
5. Phone and email
6. 3-8 key services or product categories

Then generate the complete site package at sites/$ARGUMENTS/:

- site.json — all fields populated (see SEO Requirements in CLAUDE.md)
- templates/ — layout.liquid, homepage.liquid, services.liquid, category_single.liquid,
  blog.liquid, blog_single.liquid, contact.liquid, thank-you.liquid, login.liquid,
  user.liquid, page_single.liquid, content_single.liquid, 404.liquid,
  _seo.liquid, _contact.liquid, _subscribe.liquid, _quote.liquid, _login.liquid
- data/posts.json — service category posts + 3-5 blog posts + about page content
- data/users.json — 2-3 sample team members
- data/leads.json — 2-3 sample leads

Use the example site at sites/example/ as a reference for template structure and data format.

Follow the SEO requirements defined in the project CLAUDE.md.

After generating, confirm the site is ready and provide the preview URL:
http://localhost:3000/?site=$ARGUMENTS
