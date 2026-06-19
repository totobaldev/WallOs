import { WALLPAPERS, type WallpaperItem } from './wallpapers.generated'
import './App.css'

interface RoadmapPhase {
  quarter: string
  title: string
  status: string
  tone: 'live' | 'next' | 'future'
  items: string[]
}

interface FaqItem {
  question: string
  answer: string
}

const ROADMAP_PHASES: RoadmapPhase[] = [
  {
    quarter: 'Q2 2026',
    title: 'Private Beta macOS',
    status: 'En progreso',
    tone: 'live',
    items: [
      'Catalogo 4K con colecciones destacadas y busqueda por tema.',
      'Instalacion de fondos por click y rotacion automatica configurable.',
      'Panel de rendimiento para medir uso de memoria y CPU en segundo plano.',
    ],
  },
  {
    quarter: 'Q3 2026',
    title: 'Release Candidate App Store',
    status: 'Siguiente fase',
    tone: 'next',
    items: [
      'Sincronizacion de favoritos entre dispositivos con cuenta opcional.',
      'Colecciones editoriales semanales y motor de recomendaciones.',
      'Flujo completo de firma, notarizacion y envio a App Store Connect.',
    ],
  },
  {
    quarter: 'Q4 2026',
    title: 'Expansion multiplataforma',
    status: 'Planificado',
    tone: 'future',
    items: [
      'Version iPhone/iPad aprovechando base Flutter compartida.',
      'Modo Focus y packs dinamicos vinculados al calendario del usuario.',
      'Canal para creadores con galerias curadas y royalties transparentes.',
    ],
  },
]

const FAQ_ITEMS: FaqItem[] = [
  {
    question: 'Como quitar la marca de agua en WallOs?',
    answer:
      'Puedes desbloquearla con 3 recomendaciones validas por codigo o con pago unico de CLP 5.000 en App Store.',
  },
  {
    question: 'Hay soporte durante 2026?',
    answer:
      'Si. WallOs mantiene soporte activo todo 2026 para incidencias, mejoras y nuevas colecciones.',
  },
  {
    question: 'Se lanzara para moviles y tablets?',
    answer:
      'Esta planificado. El roadmap contempla expansion progresiva para iPhone, iPad y tablets.',
  },
]

function WallpaperTile({ item }: { item: WallpaperItem }) {
  return (
    <div className="wallpaperTile">
      {item.type === 'video' ? (
        <video src={item.src} autoPlay loop muted playsInline preload="metadata" />
      ) : (
        <img src={item.src} alt="" loading="eager" />
      )}
    </div>
  )
}

function App() {
  const wallpaperPreviews = WALLPAPERS.some((item) => item.type === 'image')
    ? WALLPAPERS.filter((item) => item.type === 'image')
    : WALLPAPERS

  const laneOneItems = [...wallpaperPreviews, ...wallpaperPreviews]
  const laneTwoItems = [...laneOneItems].reverse()

  return (
    <main className="page">
      <div className="noise" aria-hidden="true" />
      <nav className="navbar" aria-label="Navegacion principal">
        <a className="navBrand" href="#inicio">
          <img className="navWordmark" src="/brand/wallos-logo.svg" alt="" aria-hidden="true" />
          <span className="navLabel">WallOs</span>
        </a>
        <div className="navLinks">
          <a href="#inicio">Inicio</a>
          <a href="#stack">Stack</a>
          <a href="#roadmap">Roadmap</a>
          <a href="#faq">FAQ</a>
          <a href="#download">Download</a>
        </div>
        <a className="btn navDownload" href="#download">
          Instalar
        </a>
      </nav>

      <header className="hero" id="inicio">
        <div className="wallpaperRails" aria-hidden="true">
          {wallpaperPreviews.length === 0 ? (
            <div className="wallpaperFallback" />
          ) : (
            <>
              <div className="wallpaperRail railOne">
                {laneOneItems.map((item, index) => (
                  <WallpaperTile key={`${item.src}-one-${index}`} item={item} />
                ))}
              </div>
              <div className="wallpaperRail railTwo">
                {laneTwoItems.map((item, index) => (
                  <WallpaperTile key={`${item.src}-two-${index}`} item={item} />
                ))}
              </div>
            </>
          )}
        </div>
        <div className="heroScrim" aria-hidden="true" />
        <div className="heroContent">
          <img className="heroLogo" src="/brand/wallos-logo.svg" alt="WallOs" />
          <p className="eyebrow">WallOs for macOS</p>
          <h1>Fondos 4K con una experiencia nativa tipo Mac.</h1>
          <p className="lead">
            Una app en Flutter para descubrir, organizar y aplicar wallpapers premium
            sin salir del flujo de trabajo.
          </p>
          <div className="ctaRow">
            <a className="btn primary" href="#download">
              Instalar WallOs para macOS
            </a>
            <a className="btn ghost" href="#stack">
              Explorar stack
            </a>
          </div>
        </div>
      </header>

      <section className="window" id="stack" aria-label="Stack principal">
        <div className="windowTop">
          <span className="dot red" />
          <span className="dot amber" />
          <span className="dot green" />
          <span className="windowTitle">Stack</span>
        </div>
        <div className="windowBody">
          <article>
            <h2>App de escritorio</h2>
            <p>Flutter (macOS primero), preparado para iOS/Android en la misma base.</p>
          </article>
          <article>
            <h2>Landing comercial</h2>
            <p>React + Vite para velocidad, SEO y experimentos de conversión.</p>
          </article>
          <article>
            <h2>Distribucion</h2>
            <p>Pipeline para App Store macOS con artefactos firmados y checklist legal.</p>
          </article>
        </div>
      </section>

      <section className="download" id="download" aria-label="Descarga de la aplicacion">
        <h2>Download de WallOs para macOS</h2>
        <p>
          Descarga la beta para Apple Silicon e Intel. Distribucion principal por App
          Store y canal directo firmado para testers.
        </p>
        <div className="downloadActions">
          <a
            className="btn primary"
            href="https://apps.apple.com/"
            target="_blank"
            rel="noreferrer"
          >
            Instalar desde App Store
          </a>
          <a className="btn ghost" href="#roadmap">
            Ver estado del release
          </a>
        </div>
      </section>

      <section className="roadmap" id="roadmap" aria-label="Roadmap inicial">
        <div className="roadmapHeader">
          <h2>Roadmap de producto</h2>
          <p>
            Plan por fases para lanzar WallOs en App Store y escalar a ecosistema
            movil sin perder la experiencia nativa.
          </p>
        </div>
        <div className="roadmapGrid">
          {ROADMAP_PHASES.map((phase) => (
            <article key={phase.quarter} className="phaseCard">
              <div className="phaseMeta">
                <p className="phaseQuarter">{phase.quarter}</p>
                <span className={`phaseStatus ${phase.tone}`}>{phase.status}</span>
              </div>
              <h3>{phase.title}</h3>
              <ul>
                {phase.items.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </article>
          ))}
        </div>
      </section>

      <section className="faq" id="faq" aria-label="Preguntas frecuentes">
        <div className="faqHeader">
          <h2>FAQ</h2>
          <p>
            Respuestas sobre desbloqueo de marca de agua, soporte 2026 y plan de expansion a
            moviles y tablets.
          </p>
        </div>
        <div className="faqGrid">
          {FAQ_ITEMS.map((item) => (
            <article key={item.question} className="faqCard">
              <h3>{item.question}</h3>
              <p>{item.answer}</p>
            </article>
          ))}
        </div>
      </section>

      <footer className="siteFooter" aria-label="Copyright">
        <p>Copyright 2026 WallOs. Todos los derechos reservados.</p>
      </footer>
    </main>
  )
}

export default App
