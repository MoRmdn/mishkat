# Share-link site — `mishkatalwird.com`

A shared thikr is `https://mishkatalwird.com/t/<thikr id>`. When Mishkat is
installed, iOS (Universal Links) and Android (App Links) open it in the app
before any page loads. When it is not, this site sends the phone to its store.

Served by Firebase Hosting on the `mishkat-al-wird` project (`firebase.json`,
`hosting` block). No Firebase SDK is involved: this is static files only.

| File | Purpose |
|---|---|
| `public/.well-known/apple-app-site-association` | Tells iOS that `/t/*` belongs to `64WR7QH47B.com.mormdn.mishkat` |
| `public/.well-known/assetlinks.json` | Tells Android which signing keys may open these links |
| `public/t/index.html` | Store redirect, for every path without a file |

## Before the first release deploy

1. ~~**App Store ID.**~~ Done: `6815677954` is in `public/t/index.html` and
   `kAppStoreId` (`lib/core/store_links.dart`).
2. **Android fingerprints.** `assetlinks.json` holds the local debug key and
   the **upload key** (`E7:33:EA:…:FE:97:E4`, from `android/app/mishkat-upload.jks`).
   Still owed: the SHA‑256 of the **app signing key**, from Play Console →
   Test and release → App integrity → *App signing key certificate*. Play
   re-signs every install, so without it no store build verifies.
3. **Domain.** Firebase console → Hosting → Add custom domain
   `mishkatalwird.com`, add the records it shows at the registrar, and let it
   redirect `www.` to the bare domain. The app only claims the bare domain.

## Deploy

```bash
firebase deploy --only hosting
```

## Check it

```bash
curl -sI https://mishkatalwird.com/.well-known/apple-app-site-association
curl -s "https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://mishkatalwird.com&relation=delegate_permission/common.handle_all_urls"
adb shell pm get-app-links com.mormdn.mishkat
adb shell am start -a android.intent.action.VIEW -d https://mishkatalwird.com/t/mo1
xcrun simctl openurl booted https://mishkatalwird.com/t/mo1
```

The first must answer `200` with `content-type: application/json` and no
redirect: iOS and Android refuse a verification file behind one. Apple fetches
it through its own CDN, which can take a day to pick up a change.
