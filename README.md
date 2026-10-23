# TRIMT HOMES — starter website

Brand: **TRIMT HOMES**  
Slogan: **Your Vision, Our Priority**  
Palette: cyan/light blue, deep navy, white.

## Included
- `index.html` — responsive front-end prototype with property search/filter, sample listings, property detail modal, demo sign-in/register, favourites, demo enquiry flow, and demo admin dashboard.
- `supabase_schema.sql` — starter PostgreSQL schema and row-level security policies for Supabase.
- This guide — low-cost deployment and production checklist.

## Important status note
The HTML page is a **front-end demo**, not yet a production application. Demo sign-in does not authenticate users, sample listings are not real listings, demo enquiries are not delivered to staff, and admin changes exist only in the current browser session. Do not use the demo password for a real account or publish unverified prices/photos as real offers. Production use requires connecting the UI to Supabase (or another backend), adding server-authorised admin actions, and testing the security rules.

## Low-cost deployment path
1. **Create a Supabase project** at https://supabase.com. Keep database passwords and service-role keys private.
2. In Supabase SQL Editor, review and run `supabase_schema.sql`. Confirm the row-level security policies before adding real customer data.
3. Configure authentication in Supabase Auth (email/password, password reset, and email confirmation as desired).
4. Create a public `property-images` Storage bucket for approved listing photos, with upload permissions limited to admins. Do not allow arbitrary public uploads.
5. Connect the UI to Supabase using its project URL and **publishable/anon key only** in browser code. Never place a service-role key in `index.html`.
6. Replace the demo `authSubmit`, `sendEnquiry`, property loading, favourites and admin functions with real Supabase calls. Protect every write with RLS plus server-side role checks. Public enquiries should have rate limits and spam protection.
7. Put `index.html` in a Git repository and deploy it using a static host such as Vercel, Netlify, or Cloudflare Pages. For this single-file prototype, no build command is needed; set the output/root directory to the project folder.
8. Add your domain and HTTPS in the host's domain settings. Test on mobile and desktop after DNS is configured.

## Suggested production architecture
- **Frontend:** HTML/CSS/JS initially; React/Next.js can be introduced as the app grows.
- **Auth:** Supabase Auth.
- **Database:** Supabase Postgres with row-level security.
- **Images:** Supabase Storage.
- **Hosting:** Vercel, Netlify, or Cloudflare Pages.
- **Email notifications:** a server/edge function with a transactional email provider; keep secrets server-side.

## Database tables
- `profiles`: user profile details linked to Supabase Auth.
- `properties`: listing title, location, type, sale/rent, NGN price, beds/baths, photos, and publication status.
- `favorites`: user's saved listings.
- `enquiries`: enquiries submitted by visitors and their status.

## Admin security requirements
- Assign the admin role only from a trusted server/dashboard, never from a public signup form.
- Keep the service-role key on the server only.
- Admin dashboard mutations must check a trusted role on the server and in database policies.
- Review and test RLS policies before launch; the schema intentionally does not grant public users write access to property listings.
- Add backups, privacy notice, terms, contact details, and a process for verifying property ownership/title before advertising listings.

## Before launch
- Replace all sample listing prices and images with approved, accurate property details.
- Add your actual contact number, email, office address, and social links.
- Test sign-up, sign-in, password reset, listing creation/editing, image upload, favourites, enquiries, admin access, and mobile layout.
- Confirm your domain, privacy policy, terms, and applicable Nigerian legal/compliance requirements.
