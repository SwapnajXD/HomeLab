console.log("Olympus V3");

const BASE = "http://100.117.35.70:8000";
const REFRESH_INTERVAL = 10000;

function safe(v, fallback = "-") {
  return v ?? fallback;
}

function renderMedia(media) {
  if (!media?.url) {
    return `
      <div class="media-panel">
        <div class="media-overlay">

          <div class="hero-chip">
            ⚡ OLYMPUS
          </div>

          <div class="media-title">Olympus</div>
          <div class="media-subtitle">Command Center</div>

        </div>
      </div>
    `;
  }

  if (media.mode === "video") {
    return `
      <div class="media-panel">

        <video
          class="media-video"
          autoplay
          muted
          loop
          playsinline>
          <source src="${media.url}">
        </video>

        <div class="media-overlay">

          <div class="hero-chip">
            🎬 MEDIA
          </div>

          <div class="media-title">
            ${safe(media.title)}
          </div>

          <div class="media-subtitle">
            ${safe(media.subtitle)}
          </div>

        </div>

      </div>
    `;
  }

  return `
    <div class="media-panel">

      <img
        class="media-image"
        src="${media.url}"
        alt="${safe(media.title)}">

      <div class="media-overlay">

        <div class="hero-chip">
          ${
            media.mode === "album"
              ? "🎵 NOW PLAYING"
              : media.mode === "wallpaper"
              ? "🖼 WALLPAPER"
              : media.mode === "anime"
              ? "🎌 ANIME"
              : media.mode === "movie"
              ? "🎬 MOVIE"
              : "🖼 MEDIA"
          }
        </div>

        <div class="media-title">
          ${safe(media.title)}
        </div>

        <div class="media-subtitle">
          ${safe(media.subtitle)}
        </div>

      </div>

    </div>
  `;
}


async function buildOlympus() {
  console.log("buildOlympus() running");
  try {
    const data = await fetch(
      `${BASE}/olympus?ts=${Date.now()}`,
      { cache: "no-store" }
    ).then(r => r.json());

    const olympusHeader = Array
      .from(document.querySelectorAll("h2"))
      .find(
        h => h.textContent.trim().toLowerCase() === "olympus"
      );

    if (!olympusHeader) return;

    const panel =
      olympusHeader
        .parentElement
        .parentElement
        .querySelector("[id*=disclosure-panel]");

    if (!panel) return;

    const media = data.media || {};
    const lastfm = data.lastfm || {};
    const library = data.library || {};
    const prices = data.prices || {};
    const weather = data.weather || {};
    const mal = data.mal || {};
    const homelab = data.homelab || {};
    const showMusicWidget = media.mode !== "album";

    panel.innerHTML = `
      <div id="olympus-hero">

        <div class="olympus-rail">

          ${showMusicWidget ? `
	  <div class="olympus-widget">
	  
	      <div class="widget-title">
	          🎵 ${safe(lastfm.status)}
	      </div>

	      <div class="music-widget">

	          ${lastfm.cover ? `
	              <img
	                  src="${lastfm.cover}"
	                  class="album-cover">
	          ` : ""}

	          <div>

	              <div class="main-text">
	                  ${safe(lastfm.track)}
	              </div>

	              <div class="sub-text">
	                  ${safe(lastfm.artist)}
	              </div>

	              <div class="tiny-text">
	                  ${safe(lastfm.elapsed)}
	              </div>

	          </div>

	      </div>

	  </div>
	  ` : ""}


          <div class="olympus-widget">
            <div class="widget-title">📚 READING</div>

            <div class="main-text">
              ${safe(library.title)}
            </div>

            <div class="sub-text">
              Chapter ${safe(library.chapter)}
            </div>

            <div class="tiny-text">
              ${safe(library.status)}
            </div>
          </div>

          <div class="olympus-widget">
            <div class="widget-title">💰 INVESTMENTS</div>

            <div class="sub-text">
              GoldBeES · ₹${prices.goldbees?.price ?? "-"}
            </div>

            <div class="sub-text">
              LiquidCase · ₹${prices.liquidcase?.price ?? "-"}
            </div>
          </div>

        </div>

        ${renderMedia(media)}

        <div class="olympus-rail">

          <div class="olympus-widget">
            <div class="widget-title">🌤 WEATHER</div>

            <div class="main-text">
              ${safe(weather.city)}
            </div>

            <div class="sub-text">
              ${safe(weather.temperature)}°
            </div>

            <div class="tiny-text">
              ${safe(weather.description)}
            </div>
          </div>

          <div class="olympus-widget">
            <div class="widget-title">🎌 ANIME</div>

            <div class="main-text">
              ${safe(mal.username)}
            </div>

            <div class="sub-text">
              Watching: ${safe(mal.watching)}
            </div>

            <div class="sub-text">
              Completed: ${safe(mal.completed)}
            </div>

            <div class="tiny-text">
              Mean Score: ${safe(mal.score)}
            </div>
          </div>

          <div class="olympus-widget">
            <div class="widget-title">🏠 HOMELAB</div>
          
            <div class="metric-row">
              <span>CPU</span>
              <span>${safe(data.homelab?.cpu)}%</span>
            </div>
          
            <div class="metric-row">
              <span>RAM</span>
              <span>${safe(data.homelab?.ram)}%</span>
            </div>
          
            <div class="metric-row">
              <span>Containers</span>
              <span>${safe(data.homelab?.containers)}</span>
            </div>
          
            <div class="metric-row">
              <span>Pods</span>
              <span>${safe(data.homelab?.pods)}</span>
            </div>
          
            <div class="tiny-text" style="margin-top:14px;">
              🟢 Athena<br>
              ${data.homelab?.services?.apollo === "online" ? "🟢" : "🔴"} Apollo<br>
              ${data.homelab?.services?.homepage === "online" ? "🟢" : "🔴"} Homepage<br>
              ${data.homelab?.services?.api === "online" ? "🟢" : "🔴"} Dashboard API<br>
              ${data.homelab?.services?.tailscale === "online" ? "🟢" : "🔴"} Tailscale
            </div>
          
            <div class="tiny-text" style="margin-top:12px;">
              Uptime: ${safe(data.homelab?.uptime)}
            </div>
          </div>

        </div>

      </div>
    `;

  } catch (err) {
    console.error("Olympus V2 Error:", err);
  }
}



let olympusStarted = false;

function startOlympus() {
  if (olympusStarted) return;

  olympusStarted = true;

  console.log("Starting Olympus");

  buildOlympus();

  setInterval(buildOlympus, REFRESH_INTERVAL);
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", startOlympus);
} else {
  startOlympus();
}
