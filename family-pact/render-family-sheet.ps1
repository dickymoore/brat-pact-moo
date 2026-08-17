$dataPath = Join-Path $PSScriptRoot "family-system-data.json"
$outPath = Join-Path $PSScriptRoot "family-system-sheet.html"

$data = Get-Content -Raw -Path $dataPath | ConvertFrom-Json

function New-ListItems {
    param([object[]]$Items)

    return (($Items | ForEach-Object {
        "        <li>$($_)</li>"
    }) -join "`n")
}

function Join-Spans {
    param([object[]]$Items)

    return (($Items | ForEach-Object {
        "      <span>$_</span>"
    }) -join "`n")
}

function Get-NavMarkup {
    param([object[]]$Items)

    $sectionMap = @{
        "Money" = "#money"
        "Phone" = "#phone"
        "Responsibilities" = "#responsibilities"
        "Rota" = "#rota"
    }

    return (($Items | ForEach-Object {
        $href = $sectionMap[$_]
        if ([string]::IsNullOrWhiteSpace($href)) {
            "      <span>$_</span>"
        } else {
            "      <a href=""$href"">$_</a>"
        }
    }) -join "`n")
}

function Get-ImageMarkup {
    param(
        [string]$Path,
        [string]$Alt,
        [string]$Caption,
        [string]$CssClass
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return @"
      <div class="$CssClass photo-card placeholder" aria-label="$Alt placeholder">
        <div class="placeholder-badge">ADD IMAGE</div>
        <div class="placeholder-copy">$Caption</div>
      </div>
"@
    }

    $captionMarkup = if ([string]::IsNullOrWhiteSpace($Caption)) { "" } else { "<figcaption>$Caption</figcaption>" }

    return @"
      <figure class="$CssClass photo-card">
        <img src="$Path" alt="$Alt" />
        $captionMarkup
      </figure>
"@
}

function Get-GalleryMarkup {
    param([object[]]$Images)

    return (($Images | ForEach-Object {
@"
          <figure class="gallery-shot">
            <img src="$($_.path)" alt="$($_.alt)" />
            <figcaption>$($_.caption)</figcaption>
          </figure>
"@
    }) -join "`n")
}

$ticker = Join-Spans $data.ticker
$navItems = Get-NavMarkup $data.masthead.nav
$callouts = Join-Spans $data.callouts
$allowanceItems = New-ListItems $data.allowance.covers
$parentsCoverItems = New-ListItems $data.allowance.parentsCover
$thresholdItems = New-ListItems $data.points.thresholds
$weekAItems = New-ListItems $data.rota.weekA
$weekBItems = New-ListItems $data.rota.weekB
$dishwasherItems = New-ListItems $data.rota.roles.dishwasher
$recyclingItems = New-ListItems $data.rota.roles.recyclingGarden
$jobItems = New-ListItems $data.jobs.items
$rewardItems = New-ListItems $data.rewards.items
$ageLevelItems = New-ListItems $data.phone.ageLevels
$curfewLevelItems = New-ListItems $data.phone.curfewLevels
$oldPhoneItems = New-ListItems $data.phone.currentOld
$galleryMarkup = Get-GalleryMarkup $data.images.gallery
function Get-CalloutRiffMarkup {
    param([object[]]$Items)

    $index = 0
    return (($Items | ForEach-Object {
        $index += 1
@"
          <article class="riff-card riff-$index">
            <span class="riff-label">$($_.label)</span>
            <p class="riff-text">$($_.text)</p>
            <p class="riff-sub">$($_.subtext)</p>
          </article>
"@
    }) -join "`n")
}

$riffA = Get-CalloutRiffMarkup $data.calloutRiff[0..1]
$riffB = Get-CalloutRiffMarkup $data.calloutRiff[2..3]
$riffC = Get-CalloutRiffMarkup $data.calloutRiff[4..5]
$riffD = Get-CalloutRiffMarkup $data.calloutRiff[6..7]

$heroImage = Get-ImageMarkup -Path $data.images.hero.path -Alt $data.images.hero.alt -Caption $data.images.hero.caption -CssClass "hero-photo"
$sideImage = Get-ImageMarkup -Path $data.images.side.path -Alt $data.images.side.alt -Caption $data.images.side.caption -CssClass "side-photo"

$html = @"
<div id="family-system-sheet">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Anybody:wght@400;700;800;900&family=Bricolage+Grotesque:wght@400;500;700&family=Playfair+Display:ital,wght@0,700;1,700&display=swap');

    #family-system-sheet {
      --acid: #98e000;
      --ink: #111111;
      --paper: #f8f7f3;
      --pink: #ef8ae7;
      --sand: #f0ede5;
      --line: #161616;
      --muted: #4b4b4b;
      color: var(--ink);
      background: var(--paper);
      font-family: "Bricolage Grotesque", sans-serif;
      line-height: 1.5;
      scroll-behavior: smooth;
    }

    #family-system-sheet .sheet {
      background:
        radial-gradient(circle at 10% 20%, rgba(152, 224, 0, 0.08), transparent 28%),
        radial-gradient(circle at 90% 12%, rgba(239, 138, 231, 0.12), transparent 24%),
        linear-gradient(180deg, #faf9f5, var(--paper));
      border: 2px solid var(--line);
      box-shadow: 8px 8px 0 #000;
      overflow: hidden;
    }

    #family-system-sheet .ticker {
      overflow: hidden;
      white-space: nowrap;
      background: #5a8500;
      color: #101700;
      border-bottom: 2px solid var(--line);
      font-family: "Anybody", sans-serif;
      font-size: 12px;
      font-weight: 700;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      padding: 7px 0;
    }

    #family-system-sheet .ticker-track {
      display: inline-flex;
      gap: 24px;
      min-width: 100%;
      padding-left: 18px;
      animation: family-sheet-marquee 30s linear infinite;
    }

    @keyframes family-sheet-marquee {
      from { transform: translateX(0); }
      to { transform: translateX(-50%); }
    }

    #family-system-sheet .masthead {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      padding: 16px 28px;
      border-bottom: 2px solid var(--line);
      background: rgba(255,255,255,0.9);
    }

    #family-system-sheet .logo {
      display: flex;
      align-items: center;
      gap: 10px;
      min-width: 0;
    }

    #family-system-sheet .logo-mark {
      width: 46px;
      height: 46px;
      display: grid;
      place-items: center;
      background: var(--acid);
      border: 2px solid var(--line);
      box-shadow: 4px 4px 0 #000;
      font-family: "Anybody", sans-serif;
      font-weight: 900;
      font-size: 12px;
      text-transform: uppercase;
      line-height: 0.95;
      text-align: center;
    }

    #family-system-sheet .logo-text {
      font-family: "Anybody", sans-serif;
      font-size: 30px;
      font-weight: 800;
      line-height: 0.95;
      text-transform: uppercase;
    }

    #family-system-sheet .nav {
      display: flex;
      flex-wrap: wrap;
      gap: 18px;
      font-family: "Anybody", sans-serif;
      font-size: 18px;
      color: var(--muted);
    }

    #family-system-sheet .nav a,
    #family-system-sheet .nav span {
      color: inherit;
      text-decoration: none;
    }

    #family-system-sheet .nav a:hover,
    #family-system-sheet .nav a:focus-visible {
      color: var(--ink);
      text-decoration: underline;
      text-decoration-color: var(--acid);
      text-decoration-thickness: 4px;
      text-underline-offset: 8px;
      outline: none;
    }

    #family-system-sheet .nav a:last-child {
      color: var(--ink);
      text-decoration: underline;
      text-decoration-color: var(--acid);
      text-decoration-thickness: 4px;
      text-underline-offset: 8px;
    }

    #family-system-sheet .layout {
      display: grid;
    }

    #family-system-sheet .section {
      padding: 28px;
    }

    #family-system-sheet .hero {
      position: relative;
      display: grid;
      grid-template-columns: 1.05fr 1fr;
      gap: 22px;
      align-items: start;
      overflow: hidden;
    }

    #family-system-sheet .hero-copy {
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      align-self: stretch;
      min-height: 100%;
      gap: 28px;
    }

    #family-system-sheet .title-card {
      position: relative;
      background: #fff;
      border: 4px solid var(--line);
      box-shadow: 8px 8px 0 #5c8900;
      padding: 22px;
      transform: rotate(-2.5deg);
      z-index: 2;
    }

    #family-system-sheet .title-card h1 {
      margin: 0;
      font-family: "Anybody", sans-serif;
      font-size: clamp(62px, 9vw, 128px);
      font-weight: 900;
      line-height: 0.84;
      letter-spacing: -0.05em;
      text-transform: uppercase;
    }

    #family-system-sheet .draft-tag {
      display: inline-block;
      margin-top: 14px;
      padding: 6px 10px;
      background: #f1f1f1;
      color: #111;
      border: 2px solid var(--line);
      font-family: "Anybody", sans-serif;
      font-size: 14px;
      font-style: italic;
      text-transform: uppercase;
    }

    #family-system-sheet .subtitle {
      margin: 16px 0 0;
      max-width: 34ch;
      font-size: 17px;
      line-height: 1.45;
      color: #333;
    }

    #family-system-sheet .photo-card {
      margin: 0;
      border: 4px solid var(--line);
      box-shadow: 8px 8px 0 #000;
      background: #fff;
      overflow: hidden;
      transform: rotate(1.5deg);
    }

    #family-system-sheet .photo-card img {
      display: block;
      width: 100%;
      height: 420px;
      object-fit: cover;
    }

    #family-system-sheet .photo-card figcaption,
    #family-system-sheet .placeholder-copy {
      padding: 12px 14px;
      font-size: 14px;
      color: #444;
    }

    #family-system-sheet .placeholder {
      min-height: 420px;
      display: grid;
      align-content: end;
      background:
        radial-gradient(circle at 80% 15%, rgba(239, 138, 231, 0.35), transparent 24%),
        radial-gradient(circle at 18% 30%, rgba(152, 224, 0, 0.34), transparent 24%),
        linear-gradient(180deg, #ffffff, #efede6);
    }

    #family-system-sheet .placeholder-badge,
    #family-system-sheet .hero-stamp,
    #family-system-sheet .callout span {
      display: inline-block;
      width: fit-content;
      padding: 7px 10px;
      color: #111;
      border: 2px solid var(--line);
      font-family: "Anybody", sans-serif;
      font-size: 12px;
      font-weight: 700;
      text-transform: uppercase;
      box-shadow: 4px 4px 0 #000;
    }

    #family-system-sheet .placeholder-badge,
    #family-system-sheet .hero-stamp {
      margin: 14px;
      background: var(--acid);
    }

    #family-system-sheet .hero-sticker {
      position: absolute;
      left: 18px;
      bottom: 70px;
      z-index: 3;
      transform: rotate(-5deg);
      padding: 12px;
      background: rgba(255,255,255,0.7);
      border: 2px solid rgba(0,0,0,0.2);
      backdrop-filter: blur(4px);
    }

    #family-system-sheet .hero-sticker div {
      background: var(--pink);
      color: #111;
      border: 2px solid var(--line);
      padding: 8px 10px;
      font-family: "Anybody", sans-serif;
      font-size: 12px;
      font-weight: 700;
      text-transform: uppercase;
      box-shadow: 4px 4px 0 #000;
      margin-top: 6px;
    }

    #family-system-sheet .callout {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin-top: 18px;
    }

    #family-system-sheet .callout span:nth-child(1) { background: #fff; color: #111; }
    #family-system-sheet .callout span:nth-child(2) { background: var(--acid); color: #111; }
    #family-system-sheet .callout span:nth-child(3) { background: var(--pink); color: #111; }

    #family-system-sheet .dark-band,
    #family-system-sheet .footer-band {
      background: #191919;
      color: #fff;
    }

    #family-system-sheet .dark-band h2,
    #family-system-sheet .light-card h3,
    #family-system-sheet .dark-card h3,
    #family-system-sheet .quote-card h3,
    #family-system-sheet .section-label {
      font-family: "Anybody", sans-serif;
      text-transform: uppercase;
    }

    #family-system-sheet .section-label {
      color: var(--acid);
      font-size: 18px;
      font-weight: 800;
      line-height: 0.9;
      margin: 0 0 16px;
      letter-spacing: -0.03em;
    }

    #family-system-sheet .formula-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 14px;
    }

    #family-system-sheet .formula-card,
    #family-system-sheet .light-card,
    #family-system-sheet .dark-card,
    #family-system-sheet .quote-card,
    #family-system-sheet .weekly-card,
    #family-system-sheet .split-table {
      border: 2px solid var(--line);
      box-shadow: 4px 4px 0 #000;
    }

    #family-system-sheet .formula-card {
      padding: 18px;
      min-height: 138px;
    }

    #family-system-sheet .formula-card:nth-child(1) { background: #fff; color: #111; transform: rotate(1deg); }
    #family-system-sheet .formula-card:nth-child(2) { background: #567e00; color: #fff; transform: rotate(-1deg); }
    #family-system-sheet .formula-card:nth-child(3) { background: var(--pink); color: #111; transform: rotate(1deg); }
    #family-system-sheet .formula-card:nth-child(4) { background: #eceae5; color: #111; transform: rotate(-1deg); }

    #family-system-sheet .card-kicker {
      display: block;
      margin-bottom: 10px;
      font-family: "Anybody", sans-serif;
      font-size: 13px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    #family-system-sheet .card-number {
      font-family: "Anybody", sans-serif;
      font-size: clamp(30px, 4vw, 42px);
      font-weight: 800;
      line-height: 0.95;
      letter-spacing: -0.04em;
      text-transform: uppercase;
    }

    #family-system-sheet .card-note {
      margin-top: 12px;
      font-size: 14px;
      line-height: 1.4;
      opacity: 1;
    }

    #family-system-sheet .editorial-grid {
      display: grid;
      grid-template-columns: 1fr 0.95fr;
      gap: 22px;
      align-items: start;
    }

    #family-system-sheet .light-card {
      background: #fff;
      padding: 22px;
      color: #111;
    }

    #family-system-sheet .light-card p,
    #family-system-sheet .light-card li,
    #family-system-sheet .light-card div,
    #family-system-sheet .split-col li {
      color: #111;
    }

    #family-system-sheet .weekly-card li {
      color: inherit;
    }

    #family-system-sheet .light-card h3,
    #family-system-sheet .dark-card h3,
    #family-system-sheet .quote-card h3,
    #family-system-sheet .split-head {
      margin: 0 0 16px;
      font-size: 16px;
      letter-spacing: 0.05em;
      font-weight: 800;
    }

    #family-system-sheet .serif-title {
      font-family: "Playfair Display", serif;
      font-size: clamp(36px, 5vw, 56px);
      font-style: italic;
      text-transform: none;
      letter-spacing: 0;
      margin-bottom: 18px;
    }

    #family-system-sheet .numbered-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: grid;
      gap: 0;
    }

    #family-system-sheet .numbered-list li {
      display: grid;
      grid-template-columns: auto 1fr;
      gap: 14px;
      align-items: start;
      padding: 14px 0;
      border-bottom: 2px solid #e6e6e6;
      font-size: 16px;
      line-height: 1.45;
    }

    #family-system-sheet .numbered-list li:last-child { border-bottom: 0; }

    #family-system-sheet .numbered-list .num {
      display: inline-grid;
      place-items: center;
      width: 30px;
      height: 30px;
      background: #5a8500;
      color: #fff;
      font-family: "Anybody", sans-serif;
      font-weight: 800;
      border: 2px solid var(--line);
    }

    #family-system-sheet .quote-card {
      background: #c700bb;
      color: #fff;
      padding: 24px;
      transform: rotate(2deg);
      margin-bottom: 18px;
    }

    #family-system-sheet .quote-card p {
      margin: 0;
      font-family: "Playfair Display", serif;
      font-size: clamp(28px, 4vw, 40px);
      font-style: italic;
      line-height: 1.1;
    }

    #family-system-sheet .stat-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 12px;
    }

    #family-system-sheet .stat-box {
      background: #fff;
      border: 2px solid var(--line);
      padding: 14px;
      color: #111;
    }

    #family-system-sheet .stat-box strong {
      display: block;
      margin-bottom: 6px;
      font-family: "Anybody", sans-serif;
      font-size: 13px;
      text-transform: uppercase;
    }

    #family-system-sheet .mini-note {
      margin-top: 12px;
      padding: 12px 14px;
      background: #f0ede5;
      border: 2px solid var(--line);
      font-size: 14px;
      color: #111;
    }

    #family-system-sheet .photo-riff {
      display: grid;
      grid-template-columns: 1.1fr 0.9fr 0.8fr;
      gap: 18px;
      align-items: end;
      margin-top: 24px;
      margin-bottom: 10px;
    }

    #family-system-sheet .gallery-shot {
      margin: 0;
      background: #fff;
      border: 3px solid var(--line);
      box-shadow: 6px 6px 0 #000;
      overflow: hidden;
      position: relative;
    }

    #family-system-sheet .gallery-shot:nth-child(1) {
      transform: rotate(-2deg);
    }

    #family-system-sheet .gallery-shot:nth-child(2) {
      transform: rotate(2deg) translateY(16px);
    }

    #family-system-sheet .gallery-shot:nth-child(3) {
      transform: rotate(-3deg) translateY(-8px);
    }

    #family-system-sheet .gallery-shot img {
      display: block;
      width: 100%;
      height: 220px;
      object-fit: cover;
    }

    #family-system-sheet .gallery-shot:nth-child(1) img { object-position: center 40%; }
    #family-system-sheet .gallery-shot:nth-child(2) img { object-position: center 35%; }
    #family-system-sheet .gallery-shot:nth-child(3) img { object-position: center 30%; }

    #family-system-sheet .gallery-shot figcaption {
      padding: 10px 12px;
      font-family: "Anybody", sans-serif;
      font-size: 12px;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: #111;
      background: #fff;
    }

    #family-system-sheet .footer-collage {
      position: relative;
      margin-top: 28px;
      padding: 28px;
      border: 2px dashed #5a8500;
      background:
        linear-gradient(180deg, rgba(255,255,255,0.03), rgba(255,255,255,0.05)),
        url('assets/20250818_125758.jpg') center 38% / cover no-repeat;
      overflow: hidden;
    }

    #family-system-sheet .footer-collage::before {
      content: "";
      position: absolute;
      inset: 0;
      background: rgba(18,18,18,0.72);
    }

    #family-system-sheet .footer-collage > * {
      position: relative;
      z-index: 1;
    }

    #family-system-sheet .flash-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 18px;
      margin-top: 22px;
    }

    #family-system-sheet .flash-card {
      background: #fff;
      color: #111;
      border: 3px solid var(--line);
      box-shadow: 6px 6px 0 #000;
      padding: 18px;
      transform: rotate(-1deg);
    }

    #family-system-sheet .flash-card.alt {
      background: var(--pink);
      transform: rotate(1.2deg);
    }

    #family-system-sheet .flash-card h4 {
      margin: 0 0 10px;
      font-family: "Anybody", sans-serif;
      font-size: 16px;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    #family-system-sheet .riff-grid {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 18px;
      margin-top: 22px;
    }

    #family-system-sheet .riff-grid.two-up {
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    #family-system-sheet .riff-card {
      border: 3px solid var(--line);
      box-shadow: 6px 6px 0 #000;
      padding: 18px;
      overflow: hidden;
      position: relative;
    }

    #family-system-sheet .riff-label {
      display: inline-block;
      margin-bottom: 10px;
      padding: 6px 10px;
      background: #fff;
      color: #111;
      border: 2px solid var(--line);
      box-shadow: 3px 3px 0 #000;
      font-family: "Anybody", sans-serif;
      font-size: 12px;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    #family-system-sheet .riff-text {
      margin: 0;
      font-family: "Playfair Display", serif;
      font-style: italic;
      font-size: clamp(24px, 3vw, 34px);
      line-height: 1.08;
    }

    #family-system-sheet .riff-sub {
      margin: 12px 0 0;
      font-size: 14px;
      line-height: 1.4;
    }

    #family-system-sheet .riff-1 {
      background: linear-gradient(135deg, #141414 0 35%, #ce1212 35% 68%, #f6d84a 68% 100%);
      color: #fff;
      transform: rotate(-2deg);
    }

    #family-system-sheet .riff-2 {
      background: linear-gradient(135deg, #98e000, #ffffff);
      color: #111;
      transform: rotate(1.4deg) translateY(14px);
    }

    #family-system-sheet .riff-3 {
      background: linear-gradient(135deg, #ffd6f4, #ff8ad8 55%, #101010 55%);
      color: #fff;
      transform: rotate(-1deg);
    }

    #family-system-sheet .riff-4 {
      background: linear-gradient(135deg, #101010, #98e000 78%);
      color: #fff;
      transform: rotate(2deg);
    }

    #family-system-sheet .riff-5 {
      background: linear-gradient(135deg, #fff, #f3ecdf);
      color: #111;
      transform: rotate(-2.4deg) translateY(-10px);
    }

    #family-system-sheet .riff-6 {
      background: linear-gradient(135deg, #b18cff, #ffffff 70%);
      color: #fff;
      transform: rotate(1deg);
    }

    #family-system-sheet .riff-7 {
      background: linear-gradient(135deg, #101010, #ffffff 82%);
      color: #fff;
      transform: rotate(-1.4deg);
    }

    #family-system-sheet .riff-8 {
      background: linear-gradient(135deg, #98e000, #ff86d8 72%);
      color: #111;
      transform: rotate(1.2deg);
    }

    #family-system-sheet .riff-3 .riff-label,
    #family-system-sheet .riff-4 .riff-label,
    #family-system-sheet .riff-6 .riff-label,
    #family-system-sheet .riff-7 .riff-label {
      background: #ffe750;
      color: #111;
    }

    #family-system-sheet .lime-section {
      background: var(--acid);
      border-top: 2px solid var(--line);
      border-bottom: 2px solid var(--line);
    }

    #family-system-sheet .baseline-grid {
      display: grid;
      grid-template-columns: 1.2fr 0.8fr;
      gap: 22px;
      align-items: start;
    }

    #family-system-sheet .check-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px 26px;
      margin-top: 18px;
    }

    #family-system-sheet .check-item {
      display: flex;
      gap: 14px;
      align-items: flex-start;
      font-family: "Anybody", sans-serif;
      font-size: 24px;
      line-height: 1.05;
      text-transform: uppercase;
    }

    #family-system-sheet .boxy {
      width: 28px;
      height: 28px;
      border: 3px solid var(--line);
      flex: 0 0 auto;
      margin-top: 2px;
      background: #fff;
    }

    #family-system-sheet .stack {
      display: grid;
      gap: 14px;
    }

    #family-system-sheet .dark-card {
      background: #1b1b1b;
      color: #fff;
      padding: 18px;
      transform: rotate(2deg);
    }

    #family-system-sheet .dark-card li,
    #family-system-sheet .dark-card div,
    #family-system-sheet .quote-card p,
    #family-system-sheet .footer-box h3 {
      color: inherit;
    }

    #family-system-sheet .pink-card {
      background: var(--pink);
      color: #111;
      transform: rotate(-1deg);
    }

    #family-system-sheet ul {
      margin: 0;
      padding-left: 20px;
      display: grid;
      gap: 8px;
      line-height: 1.45;
    }

    #family-system-sheet .split-table {
      background: #fff;
      overflow: hidden;
    }

    #family-system-sheet .split-head {
      background: #1b1b1b;
      color: #fff;
      padding: 16px 22px;
      font-style: italic;
    }

    #family-system-sheet .split-body {
      display: grid;
      grid-template-columns: 1fr 1fr;
    }

    #family-system-sheet .split-col {
      padding: 22px;
    }

    #family-system-sheet .split-col:first-child {
      border-right: 2px solid var(--line);
    }

    #family-system-sheet .split-col h4 {
      margin: 0 0 14px;
      font-family: "Anybody", sans-serif;
      font-size: 14px;
      color: #111;
      text-transform: uppercase;
      text-decoration: underline;
      text-underline-offset: 4px;
    }

    #family-system-sheet .weekly-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 22px;
    }

    #family-system-sheet .weekly-card {
      position: relative;
      padding: 22px;
      background: #fff;
      min-height: 190px;
      color: #111;
    }

    #family-system-sheet .weekly-card.dim {
      background: #202020;
      color: #cfcfcf;
      box-shadow: none;
      border-color: #888;
    }

    #family-system-sheet .active-badge {
      position: absolute;
      top: 14px;
      right: 16px;
      background: #5a8500;
      color: #fff;
      border: 2px solid var(--line);
      padding: 6px 10px;
      transform: rotate(12deg);
      font-family: "Anybody", sans-serif;
      font-size: 12px;
      font-weight: 800;
      text-transform: uppercase;
    }

    #family-system-sheet .weekly-card h3 {
      margin: 0 0 14px;
      font-family: "Anybody", sans-serif;
      font-size: 46px;
      color: inherit;
      line-height: 0.9;
      text-transform: uppercase;
    }

    #family-system-sheet .footer-band {
      text-align: center;
    }

    #family-system-sheet .footer-box {
      display: inline-block;
      padding: 28px 34px;
      border: 2px dashed #5a8500;
      background: rgba(255,255,255,0.03);
      max-width: 620px;
    }

    #family-system-sheet .footer-box h3 {
      margin: 0 0 12px;
      font-family: "Anybody", sans-serif;
      font-size: 34px;
      font-style: italic;
      text-transform: uppercase;
    }

    #family-system-sheet .footer-box p {
      margin: 0 auto 18px;
      max-width: 44ch;
      color: #d7d7d7;
      line-height: 1.5;
    }

    #family-system-sheet .footer-meta {
      margin-top: 14px;
      color: #bcbcbc;
      font-size: 13px;
    }

    @media (max-width: 980px) {
      #family-system-sheet .hero,
      #family-system-sheet .editorial-grid,
      #family-system-sheet .baseline-grid,
      #family-system-sheet .weekly-grid,
      #family-system-sheet .formula-grid,
      #family-system-sheet .stat-grid,
      #family-system-sheet .split-body,
      #family-system-sheet .photo-riff,
      #family-system-sheet .flash-row,
      #family-system-sheet .riff-grid,
      #family-system-sheet .riff-grid.two-up {
        grid-template-columns: 1fr;
      }

      #family-system-sheet .check-grid {
        grid-template-columns: 1fr;
      }

      #family-system-sheet .masthead {
        flex-direction: column;
        align-items: flex-start;
      }
    }

    @media (max-width: 640px) {
      #family-system-sheet .section,
      #family-system-sheet .masthead {
        padding: 18px;
      }

      #family-system-sheet .logo-text {
        font-size: 24px;
      }

      #family-system-sheet .title-card {
        padding: 16px;
      }

      #family-system-sheet .photo-card img,
      #family-system-sheet .placeholder {
        height: auto;
        min-height: 280px;
      }
    }
  </style>

  <div class="sheet" role="img" aria-label="Editorial-style Brat Pact sheet covering allowance, phone rules, daily expectations, points, paid jobs and weekly rota.">
    <div class="ticker">
      <div class="ticker-track">
$ticker
$ticker
      </div>
    </div>

    <div class="masthead">
      <div class="logo">
        <div class="logo-mark">brat<br/>pact</div>
        <div class="logo-text">$($data.masthead.label)</div>
      </div>
      <div class="nav">
$navItems
      </div>
    </div>

    <div class="layout">
      <section class="section hero">
        <div class="hero-copy">
          <div class="title-card">
            <h1>Brat<br/>Pact</h1>
            <div class="draft-tag">Working draft | review: $($data.reviewDate)</div>
          </div>
          <div class="callout">
$callouts
          </div>
        </div>
        <div style="position:relative;">
          $heroImage
          <div class="hero-sticker">
            <div>Phone boundaries</div>
            <div>Shared expectations</div>
          </div>
          <div class="hero-stamp">Est. Summer 2026</div>
        </div>
      </section>

      <section id="money" class="section dark-band">
        <h2 class="section-label">The Formula</h2>
        <div class="formula-grid">
          <div class="formula-card">
            <span class="card-kicker">Allowance formula</span>
            <div class="card-number">$($data.allowance.formula)</div>
            <p class="card-note">$($data.allowance.kit)<br/>$($data.allowance.obie)</p>
          </div>
          <div class="formula-card">
            <span class="card-kicker">Phone formula</span>
            <div class="card-number">$($data.phone.kit)</div>
            <p class="card-note">$($data.phone.obie)<br/>Spotify and WhatsApp are unlimited until curfew for music and social planning.</p>
          </div>
          <div class="formula-card">
            <span class="card-kicker">Allowance depends on</span>
            <div class="card-number">Daily baseline<br/>+ lead jobs</div>
            <p class="card-note">Dishwasher lead, recycling lead, and the everyday baseline all need to be done.</p>
          </div>
          <div class="formula-card">
            <span class="card-kicker">Current monthly amounts</span>
            <div class="card-number">Kit: £40<br/>Obie: £35</div>
            <p class="card-note">Base allowance first. Extra money comes from paid jobs.<br/>$($data.allowance.schoolTermExtra)</p>
          </div>
        </div>
      </section>

      <section id="phone" class="section">
        <div class="editorial-grid">
          <div class="light-card">
            <h3 class="serif-title">Phone Boundaries</h3>
            <ol class="numbered-list">
              <li><span class="num">01</span><span>Spotify and WhatsApp are unlimited until curfew for music and social planning.</span></li>
              <li><span class="num">02</span><span>If you are at a social event, WhatsApp stays available for practical plans, but the phone should stay mostly away.</span></li>
              <li><span class="num">03</span><span>Budget your limited phone time for TikTok, YouTube, games and other non-essential apps.</span></li>
              <li><span class="num">04</span><span>No phones in bed, and no TikTok, Shorts or Reels in the first hour after waking or the final hour before bed.</span></li>
              <li><span class="num">05</span><span>Phones charge downstairs overnight, and the same boundaries apply on laptops and TV.</span></li>
            </ol>
          </div>

          <div>
            <h2 class="section-label" style="color:#1b1b1b;">How this works</h2>
            <div class="quote-card">
              <p>"Clearer expectations make more freedom easier."</p>
            </div>
            <div class="stat-grid">
              <div class="stat-box">
                <strong>Old limits</strong>
                <div>$($data.phone.currentOld[0])</div>
              </div>
              <div class="stat-box">
                <strong>Old limits</strong>
                <div>$($data.phone.currentOld[1])</div>
              </div>
              <div class="stat-box">
                <strong>Unlimited</strong>
                <div>WhatsApp and Spotify until curfew</div>
              </div>
            </div>
            <div style="margin-top:18px;">
              $sideImage
            </div>
          </div>
        </div>

      </section>

      <section id="responsibilities" class="section lime-section">
        <div class="baseline-grid">
          <div class="light-card" style="transform:rotate(-1deg);">
            <h3>Daily baseline</h3>
            <div style="margin-bottom:10px; font-size:16px;">$($data.daily.title)</div>
            <div class="check-grid">
              <div class="check-item"><span class="boxy"></span><span>Laundry in basket</span></div>
              <div class="check-item"><span class="boxy"></span><span>Bags and shoes put away</span></div>
              <div class="check-item"><span class="boxy"></span><span>Wrappers and dishes cleared</span></div>
              <div class="check-item"><span class="boxy"></span><span>No bowls or glasses left in bedrooms overnight</span></div>
              <div class="check-item"><span class="boxy"></span><span>Bedroom floor clear</span></div>
              <div class="check-item"><span class="boxy"></span><span>Own mess cleared from shared rooms</span></div>
            </div>
          </div>

          <div class="stack">
            <div class="dark-card">
              <h3>Yellow and red cards</h3>
              <ul>
$thresholdItems
              </ul>
            </div>
            <div class="dark-card pink-card">
              <h3>Allowance summary</h3>
              <div style="font-size:14px; margin-bottom:10px;">Regular allowance depends on the baseline plus the two lead jobs.</div>
              <ul>
                <li>Daily baseline done</li>
                <li>Dishwasher lead or recycling lead done properly</li>
                <li>Extra money can still be earned separately through paid jobs</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      <section class="section">
        <div class="split-table">
          <div class="split-head">The monthly payout split</div>
          <div class="split-body">
            <div class="split-col">
              <h4>Children cover</h4>
              <ul>
$allowanceItems
              </ul>
            </div>
            <div class="split-col" style="background:#eceae5;">
              <h4>Parents cover</h4>
              <ul>
$parentsCoverItems
              </ul>
            </div>
          </div>
        </div>

        <div class="photo-riff">
$galleryMarkup
        </div>
      </section>

      <section id="rota" class="section footer-band">
        <div class="weekly-grid">
          <div class="weekly-card">
            <div class="active-badge">$($data.rota.activeWeek)</div>
            <h3>Week A</h3>
            <ul>
$weekAItems
            </ul>
          </div>
          <div class="weekly-card dim">
            <h3>Week B</h3>
            <ul>
$weekBItems
            </ul>
          </div>
        </div>

        <div class="riff-grid two-up" style="margin-top:22px;">
$riffA
        </div>

        <div class="editorial-grid" style="margin-top:22px; align-items:start;">
          <div class="light-card">
            <h3>Dishwasher lead</h3>
            <ul>
$dishwasherItems
            </ul>
          </div>
          <div class="light-card">
            <h3>Recycling and garden lead</h3>
            <ul>
$recyclingItems
            </ul>
          </div>
        </div>

        <div class="editorial-grid" style="margin-top:22px; align-items:start;">
          <div class="light-card">
            <h3>Phone age levels</h3>
            <ul>
$ageLevelItems
            </ul>
            <div class="mini-note">
              <strong>Current/old limits:</strong>
              <ul style="margin-top:8px;">
$oldPhoneItems
              </ul>
            </div>
            <div class="mini-note">
              <strong>Phone time note:</strong> Spotify and WhatsApp do not need budgeting. TikTok, YouTube, games and other non-essential apps do.
            </div>
          </div>
          <div class="light-card">
            <h3>Phone curfew times</h3>
            <div class="mini-note" style="margin-top:0; margin-bottom:14px;">
              <strong>Usual rule:</strong> $($data.phone.curfewFormula)
            </div>
            <div class="mini-note" style="margin-top:0; margin-bottom:14px;">
              <strong>Holiday bonus:</strong> $($data.phone.holidayBonus)
            </div>
            <ul>
$curfewLevelItems
            </ul>
          </div>
        </div>

        <div class="editorial-grid" style="margin-top:22px; align-items:start;">
          <div class="light-card">
            <h3>Allowance depends on</h3>
            <div class="mini-note" style="margin-top:0; margin-bottom:14px;">
              <strong>Core rule:</strong> daily baseline + dishwasher lead + recycling lead
            </div>
            <ul>
              <li>The everyday baseline needs to be done without repeated reminders.</li>
              <li>The weekly lead job needs to be done properly.</li>
              <li>This is the basis for the regular allowance.</li>
            </ul>
          </div>
          <div class="light-card">
            <h3>Current monthly amounts</h3>
            <div class="mini-note" style="margin-top:0; margin-bottom:14px;">
              <strong>Base allowance:</strong> Kit: £40 | Obie: £35
            </div>
            <div>$($data.allowance.schoolTermExtra)</div>
            <div class="mini-note">
              <strong>Reminder:</strong> Base allowance first. Extra money comes from paid jobs.
            </div>
          </div>
        </div>

        <div class="riff-grid two-up" style="margin-top:22px;">
$riffB
        </div>

        <div class="editorial-grid" style="margin-top:22px; align-items:start;">
          <div class="light-card">
            <h3>Yellow and red cards</h3>
            <ul>
$thresholdItems
            </ul>
          </div>
          <div class="light-card">
            <h3>$($data.rewards.headline)</h3>
            <ul>
$rewardItems
            </ul>
          </div>
        </div>

        <div class="riff-grid two-up" style="margin-top:22px;">
$riffC
        </div>

        <div class="editorial-grid" style="margin-top:22px; align-items:start;">
          <div class="light-card">
            <h3>Extra paid jobs</h3>
            <div class="mini-note" style="margin-top:0; margin-bottom:14px;">
              <strong>Rate:</strong> $($data.jobs.rate)
            </div>
            <ul>
$jobItems
            </ul>
          </div>
          <div class="light-card">
            <h3>What allowance covers</h3>
            <div class="mini-note">
              <strong>Children cover:</strong> clothes, haircuts, treats, social spending, deodorant and specialist toiletries.
            </div>
            <div class="mini-note">
              <strong>Parents cover:</strong> uniform, required shoes or kit, winter coat, basic toiletries, kitchen food and the phone contract.
            </div>
          </div>
        </div>

        <div class="riff-grid two-up" style="margin-top:24px;">
$riffD
        </div>

        <div class="footer-collage">
          <div class="flash-row">
            <div class="flash-card">
              <h4>Shared plan</h4>
              <p>The aim is clearer routines, calmer conversations and more independence that actually works.</p>
            </div>
            <div class="flash-card alt">
              <h4>What good looks like</h4>
              <p>Baseline done, lead jobs done, phones budgeted sensibly, and shared spaces reset without drama.</p>
            </div>
          </div>

          <div class="footer-box" style="margin-top:32px;">
            <h3>Ready to try it?</h3>
            <p>This version aims to keep the expectations clear: what the allowance is based on, what the phone rules are, and how extra money can still be earned.</p>
            <div class="footer-meta">Phone spreadsheet formula: <code>$($data.phone.spreadsheet)</code> | Edit <code>family-system-data.json</code> and rerender to update.</div>
          </div>
        </div>
      </section>
    </div>
  </div>
</div>
"@

Set-Content -Path $outPath -Value $html
