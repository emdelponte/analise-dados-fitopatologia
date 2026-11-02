// Estilo do livro em PDF (Typst), feito para se parecer com a versão HTML
// (style.scss): fontes Inter e JetBrains Mono, paleta verde-oliva, títulos
// de seção com barra lateral, código em caixas claras e callouts discretos.
// Substitui o modelo padrão de livros do Quarto (orange-book).

// ---------- Paleta (mesmos valores do style.scss) ----------
#let verde        = rgb("#5f7132")
#let verde-escuro = rgb("#2c3a22")
#let verde-claro  = rgb("#c9dba0")
#let verde-papel  = rgb("#f4f7ee")
#let verde-link   = rgb("#4b6a1f")
#let tinta        = rgb("#1f2a1b")
#let cinza        = rgb("#6b7464")
#let linha        = rgb("#e3e8da")
#let fundo-codigo = rgb("#f6f8f2")

#let fonte-texto  = ("Inter", "Segoe UI", "Noto Sans")
#let fonte-codigo = ("JetBrains Mono", "Consolas")

// ---------- Callouts (substitui a função padrão do Quarto) ----------
// As cores dependem do tipo, identificado pela cor do ícone enviada pelo Quarto.
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"),
             icon: none, icon_color: black, body_background_color: white) = {
  let cor = icon_color
  let fundo = icon_color.lighten(94%)
  if icon_color == rgb("#00A047") { cor = verde; fundo = verde-papel }   // tip
  if icon_color == rgb("#CC1914") { fundo = rgb("#fbf3f2") }             // important
  if icon_color == rgb("#0758E5") { fundo = rgb("#f1f6fb") }             // note
  if icon_color == rgb("#EB9113") { fundo = rgb("#fdf7ea") }             // warning
  let cor-titulo = if cor == verde { verde-escuro } else { cor.darken(15%) }
  // mesma estrutura de blocos aninhados do Quarto (usada nas referências cruzadas)
  block(
    breakable: true,
    fill: fundo,
    stroke: (left: 3.5pt + cor, rest: 0.6pt + linha),
    radius: 6pt,
    width: 100%,
    block(
      inset: 0pt,
      width: 100%,
      below: 0pt,
      block(width: 100%, inset: (x: 11pt, top: 9pt, bottom: 7pt))[#text(weight: 600, fill: cor-titulo)[#if icon != none [#text(cor)[#icon] ]#title]]) +
    if body != [] {
      block(inset: 0pt, width: 100%,
        block(width: 100%, inset: (x: 11pt, top: 4pt, bottom: 10pt), body))
    }
  )
}

#set document(
$if(title)$
  title: [$title$],
$endif$
$if(by-author)$
  author: "$for(by-author)$$it.name.literal$$sep$, $endfor$",
$endif$
)

// ---------- Capa: cover.png em página inteira ----------
#page(paper: "a4", margin: 0pt, header: none, footer: none, numbering: none)[
  #image("cover.png", width: 100%, height: 100%, fit: "cover")
]

// ---------- Verso da capa: créditos, ficha catalográfica e como citar ----------
// Os dados vêm do campo "livro" do _quarto.yml.
#page(paper: "a4", margin: (x: 2.5cm, top: 2.6cm, bottom: 2.4cm),
      header: none, footer: none, numbering: none)[
  #set text(font: fonte-texto, size: 8.3pt, fill: tinta, lang: "pt")
  #set par(leading: 0.65em, spacing: 0.9em, justify: false)
  #show link: set text(fill: verde-link)

  #text(size: 10pt, weight: 700, fill: verde-escuro)[$title$]

  © $livro.ano$ $for(by-author)$$it.name.literal$$sep$, $endfor$

  Esta obra está licenciada sob a licença Creative Commons Atribuição-NãoComercial 4.0 Internacional (CC BY-NC 4.0). É permitido copiar, distribuir, imprimir e adaptar o conteúdo para fins não comerciais, desde que seja atribuído o devido crédito ao autor. Texto da licença: #link("https://creativecommons.org/licenses/by-nc/4.0/deed.pt-br")[creativecommons.org/licenses/by-nc/4.0].

  Os códigos em R apresentados no livro podem ser reutilizados livremente.

  #grid(columns: (auto, 1fr), column-gutter: 1em, row-gutter: 0.55em,
    text(weight: 600)[Edição], [#"$livro.edicao$", $livro.local$: $livro.editora$, $livro.ano$],
    text(weight: 600)[ISBN], [$livro.isbn$],
    text(weight: 600)[DOI], [$livro.doi$],
    text(weight: 600)[Versão online], [$livro.url$],
    text(weight: 600)[Código-fonte], link("https://github.com/emdelponte/analise-dados-fitopatologia")[github.com/emdelponte/analise-dados-fitopatologia],
  )

  #v(1fr)

  // ficha catalográfica (tamanho padrão de 12,5 × 7,5 cm), a ser preenchida
  // com o texto elaborado pela Biblioteca Central da UFV
  #align(center)[
    #text(size: 7.5pt, fill: cinza)[Ficha catalográfica elaborada pela Biblioteca Central da Universidade Federal de Viçosa]
    #v(-0.3em)
    #block(width: 12.5cm, height: 7.5cm, stroke: 0.6pt + cinza, inset: 10pt)[
      #set text(font: fonte-codigo, size: 7.5pt)
      #align(center + horizon, text(fill: cinza)[\[ficha catalográfica a ser inserida\]])
    ]
  ]

  #v(1.2em)
  #text(weight: 700, fill: verde-escuro)[Como citar]

  DEL PONTE, E. M. *$title$*. $livro.edicao$ $livro.local$: $livro.editora$, $livro.ano$. Disponível em: $livro.url$. DOI: $livro.doi$.
]

// ---------- Página ----------
#set page(
  paper: "a4",
  margin: (inside: 2.7cm, outside: 2.3cm, top: 2.6cm, bottom: 2.4cm),
  header: context {
    let pagina = here().page()
    // sem cabeçalho na página de abertura de um capítulo
    if query(heading.where(level: 1)).any(h => h.location().page() == pagina) { return }
    let anteriores = query(heading.where(level: 1).before(here()))
    if anteriores.len() == 0 { return }
    let cap = anteriores.last()
    let rotulo = if cap.numbering != none {
      [#counter(heading).at(cap.location()).first()#h(0.6em)#cap.body]
    } else { cap.body }
    set text(size: 8pt, fill: cinza)
    if calc.even(pagina) {
      [#counter(page).display() #h(1fr) #rotulo]
    } else {
      [#rotulo #h(1fr) #counter(page).display()]
    }
    v(-0.3em)
    line(length: 100%, stroke: 0.5pt + linha)
  },
  footer: context {
    // número da página no rodapé apenas nas aberturas de capítulo
    let pagina = here().page()
    if query(heading.where(level: 1)).any(h => h.location().page() == pagina) {
      align(center, text(size: 8pt, fill: cinza, counter(page).display()))
    }
  },
)

// ---------- Texto ----------
#set text(font: fonte-texto, size: 9.8pt, fill: tinta, lang: "pt", region: "BR")
#set par(justify: false, leading: 0.78em, spacing: 1.15em)
#show link: set text(fill: verde-link)
#show ref: set text(fill: verde-link)
#set list(indent: 0.6em, body-indent: 0.5em, marker: ([•], [–]))
#set enum(indent: 0.6em, body-indent: 0.5em)
#show strong: set text(weight: 600)

// ---------- Código ----------
#show raw: set text(font: fonte-codigo, size: 8.2pt)
#let caixa-codigo = (fill: fundo-codigo, stroke: 0.6pt + linha, radius: 6pt,
                     inset: (x: 10pt, y: 9pt), width: 100%, above: 1em, below: 1em)

// O código com realce de sintaxe chega como uma sequência de trechos "raw"
// em linha (um por token); este estado evita que o estilo de código em linha
// seja aplicado a esses trechos.
#let em-bloco = state("em-bloco", false)
#let Skylighting(fill: none, number: false, start: 1, sourcelines) = {
  let linhas = []
  for ln in sourcelines { linhas = linhas + ln + EndLine() }
  em-bloco.update(true)
  block(..caixa-codigo, par(leading: 0.62em, linhas))
  em-bloco.update(false)
}

#show raw.where(block: false): it => context {
  if em-bloco.get() { it } else {
    box(fill: rgb("#f3f5ef"), inset: (x: 2.5pt), outset: (y: 2.5pt), radius: 3pt,
        text(fill: rgb("#8a4b1c"), it))
  }
}
#show raw.where(block: true): set block(..caixa-codigo)
#show raw.where(block: true): set par(leading: 0.62em)

// ---------- Títulos ----------
#set heading(numbering: "1.1.1")
#show heading: set text(fill: verde-escuro, weight: 700)

// capítulos: página ímpar, rótulo "Capítulo N" em verde e título grande
#show heading.where(level: 1): it => {
  // reinicia a numeração de figuras, tabelas e equações a cada capítulo
  counter(figure.where(kind: "quarto-float-fig")).update(0)
  counter(figure.where(kind: "quarto-float-tbl")).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)
  pagebreak(weak: true, to: "odd")
  v(2cm)
  block(width: 100%, below: 1.5cm)[
    #if it.numbering != none {
      text(size: 10.5pt, weight: 600, fill: verde, tracking: 0.1em,
           upper[Capítulo #counter(heading).display("1")])
      v(0.5em)
    }
    #text(size: 23pt, weight: 800, fill: verde-escuro, tracking: -0.02em,
          par(leading: 0.45em, it.body))
    #v(0.8em)
    #line(length: 3.2cm, stroke: 2.5pt + verde-claro)
  ]
}

// seções: barra lateral verde-clara, como no HTML
#show heading.where(level: 2): it => {
  set text(size: 13.5pt, tracking: -0.015em)
  block(above: 2em, below: 1em, sticky: true,
    stroke: (left: 3.5pt + verde-claro), inset: (left: 9pt, y: 2pt))[
    #if it.numbering != none {
      text(fill: verde, counter(heading).display(it.numbering))
      h(0.6em)
    }
    #it.body
  ]
}

#show heading.where(level: 3): it => {
  set text(size: 11.3pt, fill: verde)
  block(above: 1.7em, below: 0.8em, sticky: true)[
    #if it.numbering != none {
      counter(heading).display(it.numbering)
      h(0.55em)
    }
    #it.body
  ]
}

#show heading.where(level: 4): it => {
  set text(size: 10.3pt, fill: cinza, weight: 600)
  block(above: 1.4em, below: 0.7em, sticky: true, it.body)
}

// ---------- Figuras e tabelas ----------
#show figure: set block(above: 1.6em, below: 1.8em)
// numeração por capítulo: Figura 1.1, Tabela 2.3...
#set figure(numbering: n => numbering("1.1", counter(heading).get().first(), n))
#set figure.caption(separator: [. ])
#show figure.caption: it => {
  set text(size: 8.6pt, fill: cinza)
  set par(leading: 0.6em)
  [#text(weight: 600)[#it.supplement #context it.counter.display(it.numbering)#it.separator]#it.body]
}

#set table(
  stroke: none,
  inset: (x: 7pt, y: 5pt),
  fill: (x, y) => if y > 0 and calc.even(y) { rgb("#fafbf7") },
)
#set table.hline(stroke: 0.7pt + verde)
#show table.cell.where(y: 0): set text(weight: 600, fill: verde-escuro)
#show table: set text(size: 8.8pt)

// ---------- Citações ----------
#show quote.where(block: true): it => block(
  stroke: (left: 3pt + verde-claro), inset: (left: 12pt, y: 4pt),
  text(fill: rgb("#3d4836"), size: 10.3pt, it.body))

// ---------- Sumário ----------
#counter(page).update(1)
$if(toc)$
#[
  #show outline.entry.where(level: 1): it => {
    v(1em, weak: true)
    text(weight: 700, fill: verde-escuro, size: 10.5pt, it)
  }
  #show outline.entry.where(level: 2): set text(size: 9.2pt)
  #set outline.entry(fill: repeat(text(fill: verde-claro)[.], gap: 0.3em))
  #outline(
    title: [$if(toc-title)$$toc-title$$else$Sumário$endif$],
    depth: $if(toc-depth)$$toc-depth$$else$2$endif$,
    indent: auto,
  )
]
$endif$

// ---------- Referências ----------
// a lista entra logo abaixo do título do capítulo "Referências"
#set bibliography(title: none)
#show bibliography: set par(hanging-indent: 1.2em, spacing: 0.9em)
#show bibliography: set text(size: 9pt)
