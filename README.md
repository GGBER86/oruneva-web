# ORUNEVA — website

Static site. One HTML file, a folder of images, no build step, no framework, no database.

```
index.html           the whole site (9 pages, hash routing)
img/                 photographs and concept renders
favicon.svg          the ORUNEVA mark
og-image.jpg         link preview card (1200×630)
robots.txt           crawler policy
sitemap.xml          one URL — see "SEO" below
_headers             security headers (Netlify reads this)
_redirects           every path resolves to index.html
netlify.toml         build settings (there is no build)
self-host-fonts.sh   run once — see "Fonts" below
```

## Deploy — from GitHub (recommended)

This folder is already a git repository with one commit in it. What is missing is the
remote: an empty repository on your GitHub account to push it to.

**1. Create the empty repo.** On github.com → *New repository* → name it `oruneva-web`
→ **Private** → do **not** add a README, .gitignore or licence (the folder already has
them; adding them creates a conflict on the first push). Create.

**2. Push.** In Terminal, from this folder:

```bash
git remote add origin https://github.com/GGBER86/oruneva-web.git
git push -u origin main
```

GitHub will ask to authenticate. Use a personal access token as the password
(*Settings → Developer settings → Personal access tokens → Fine-grained*, with
**Contents: read and write** on this repository), or install GitHub Desktop and let it
handle the login.

**3. Connect Netlify.** Netlify → *Add new site* → *Import an existing project* →
GitHub → pick `oruneva-web`. Settings:

| Field | Value |
|---|---|
| Branch to deploy | `main` |
| Build command | *(leave empty)* |
| Publish directory | `.` |

From then on: every `git push` redeploys the site automatically, and every pull request
gets its own preview URL you can send to someone before it goes live.

### Making a change later

```bash
# edit index.html
git add -A
git commit -m "Update the For Locations copy"
git push
```

Netlify picks it up within a minute. If you break something, `git revert` the commit and
push — the previous version is back. That is the whole reason to do it this way rather
than dragging a folder.

## Deploy — drag and drop (faster, no versioning)

Netlify → *Add new site* → *Deploy manually* → drag this folder onto the drop area.
Live in about thirty seconds. Fine for a first look; switch to GitHub before the site
starts mattering.

## Connect oruneva.com

You keep the domain where it is. You only change where it points.

1. In Netlify: *Domain management* → *Add a domain* → `oruneva.com`. Netlify will say
   it is registered elsewhere — that is expected. Choose **Add domain**.
2. Netlify gives you four nameservers, like `dns1.p01.nsone.net`.
3. At your registrar, replace the current nameservers with those four.
4. Wait. Usually under an hour, up to 24.

Netlify then issues a free Let's Encrypt certificate automatically and `www` redirects
to the apex. This is the simplest route and the one to take unless the registrar is
also running mail or other records you would rather not move.

**If you want to keep DNS at the registrar instead**, do not change nameservers.
Add these two records there:

| Type | Name | Value |
|---|---|---|
| A | `@` | `75.2.60.5` |
| CNAME | `www` | `your-site-name.netlify.app` |

Netlify publishes its current load-balancer IP in its own docs — check it before you
type it, it has changed before. The nameserver route avoids this problem entirely.

**Email is separate.** Netlify does not host mail. `info@oruneva.com` needs an MX
record wherever you set up the mailbox. If you delegate nameservers to Netlify, the MX
records have to be recreated in Netlify DNS or the address will stop receiving.

## The contact form — one switch you must flip

The HTML is already wired for Netlify Forms. **But Netlify does not look for forms
unless you tell it to**, and it only starts looking from the *next* deploy. So:

1. Deploy the site once (either method above).
2. Netlify dashboard → **Forms** → **Enable form detection**.
3. **Deploy again.** From the Git flow, an empty commit is enough:
   `git commit --allow-empty -m "Trigger form detection" && git push`

After that deploy, a form named **`location`** appears under *Forms*. Open it →
*Settings and usage* → **Form notifications** → add an email notification to
`info@oruneva.com`, otherwise submissions sit in the dashboard and nobody sees them.

If you skip step 2 you will get no error anywhere. The form will simply appear to work
and the submissions will go nowhere — this is the single most common way this setup
fails, so test it yourself once before sending the link to anyone.

**What is already in place:** the form is named `location`, carries
`data-netlify="true"`, includes the hidden `form-name` field the AJAX POST needs, and
has a honeypot field (`company-website`) that catches most bots without a CAPTCHA. The
POST goes to `/` as URL-encoded data, which is what Netlify expects.

**The fallback:** if the POST fails — a local preview, another host, form detection not
enabled — the page composes the same summary as an email to `info@oruneva.com` instead,
and tells the sender which of the two happened. Nothing is silently lost.

Free tier: 100 submissions a month. For a location search that is plenty; if it is not,
that is a good problem.

## Fonts — do this before promoting the site in Germany

The page currently loads Archivo and Azeret Mono from Google's servers, which sends
every visitor's IP address to Google. A Munich court awarded damages against a site
operator for precisely this (LG München I, 3 O 17493/20). One command fixes it:

```bash
chmod +x self-host-fonts.sh && ./self-host-fonts.sh
```

It downloads the font files into `fonts/`, repoints the page at them, and tightens the
Content-Security-Policy. After that the site makes no third-party request at all —
which is what lets the cookie page say, truthfully, that no banner is needed.
Then delete the section headed "The one external request" from the cookie page.

## SEO — one honest limitation

The site is a single page with hash routing (`/#/locations`). Search engines index the
root URL and nothing else: the nine pages are not nine indexable addresses. That is
fine while the job is to be shown in meetings and sent by link. When organic search
starts to matter, the pages need real paths, which means splitting the file or moving
to a framework. The content is already separated from the components, so that is a
day's work, not a rebuild.

## What still needs a professional

Three pages carry a visible `REQUIRES PROFESSIONAL VALIDATION` box — Imprint, Privacy,
Cookies. The company data in them is taken from the Italian register extract and is
correct. What has not been checked by a lawyer is the German side: whether operating a
site in Berlin creates a permanent establishment, and what that triggers for VAT, trade
registration, lodging rules and the Impressum. That review belongs before the first
signature, not before the first meeting.
