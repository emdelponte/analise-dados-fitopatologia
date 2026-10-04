# Funções auxiliares para os diagramas de fluxo do livro (DiagrammeR/Graphviz).
# Uso nos capítulos: source("R/diagramas.R") em um bloco com include: false.

# Paleta pastel usada nas figuras do livro: preenchimento, borda e texto.
paleta_livro <- list(
  azul    = c("#eaf2fb", "#7fa7d6", "#1f5fa8"),
  verde   = c("#eef6e8", "#9cc27f", "#4f7d2f"),
  amarelo = c("#fdf5e1", "#e5c46e", "#9a6b00"),
  roxo    = c("#f2edf8", "#b3a1d4", "#6c4f9e"),
  turquesa = c("#e6f5f3", "#86c9bf", "#1f8075"),
  coral   = c("#fcebe9", "#eba39a", "#c4473a"),
  cinza   = c("#f4f4f4", "#bbbbbb", "#666666")
)

# Escapa caracteres especiais para rótulos HTML do Graphviz.
esc_html <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x
}

# Rótulo de um nó: título em negrito e, opcionalmente, um detalhe abaixo.
rotulo_no <- function(titulo, detalhe = NA, cor_texto = "#24301f",
                      cor_detalhe = "#555555") {
  # Quebra títulos longos em duas linhas (o Graphviz subestima a largura do texto).
  if (!grepl("\n", titulo, fixed = TRUE) && nchar(titulo) > 40) {
    titulo <- paste(strwrap(titulo, width = ceiling(nchar(titulo) / 2) + 4),
                    collapse = "\n")
  }
  titulo <- gsub("\n", "<br/>", esc_html(titulo), fixed = TRUE)
  lab <- sprintf("<b>%s</b>", titulo)
  if (!is.na(detalhe) && nzchar(detalhe)) {
    detalhe <- gsub("\n", "<br/>", esc_html(detalhe), fixed = TRUE)
    lab <- sprintf("%s<br/><font point-size='12' color='%s'>%s</font>",
                   lab, cor_detalhe, detalhe)
  }
  sprintf("<<font color='%s'>%s</font>>", cor_texto, lab)
}

# Fluxo linear vertical.
#   etapas:   vetor com os títulos das etapas
#   detalhes: vetor opcional (mesmo comprimento) com um texto menor sob cada título
#   cores:    nomes de cores de paleta_livro, recicladas ao longo das etapas
#   retorno:  par opcional c(de, para) de índices para uma seta tracejada de volta
#   rotulo_retorno: texto da seta de retorno
fluxo <- function(etapas, detalhes = NULL,
                  cores = c("azul", "verde", "amarelo", "roxo",
                            "turquesa", "coral"),
                  largura = 4.6, retorno = NULL,
                  rotulo_retorno = "revisar", altura = NULL) {
  k <- length(etapas)
  if (is.null(detalhes)) detalhes <- rep(NA, k)
  cores <- rep(cores, length.out = k)

  nos <- vapply(seq_len(k), function(i) {
    p <- paleta_livro[[cores[i]]]
    sprintf("  n%d [label = %s, fillcolor = '%s', color = '%s']",
            i, rotulo_no(etapas[i], detalhes[i], "#24301f", p[3]), p[1], p[2])
  }, character(1))

  arestas <- paste(sprintf("n%d", seq_len(k)), collapse = " -> ")

  volta <- ""
  if (!is.null(retorno)) {
    volta <- sprintf(
      "  n%d -> n%d [style = dashed, color = '#999999', constraint = false, label = '  %s', fontcolor = '#777777']",
      retorno[1], retorno[2], esc_html(rotulo_retorno))
  }

  if (is.null(altura)) {
    linhas <- vapply(seq_len(k), function(i) {
      lt <- if (grepl("\n", etapas[i], fixed = TRUE)) {
        length(strsplit(etapas[i], "\n", fixed = TRUE)[[1]])
      } else if (nchar(etapas[i]) > 40) 2 else 1
      ld <- if (is.na(detalhes[i])) 0 else
        length(strsplit(detalhes[i], "\n", fixed = TRUE)[[1]])
      lt + ld
    }, numeric(1))
    altura <- sum(42 + 20 * linhas) + 30
  }

  dot <- paste0(
    "digraph fluxo {\n",
    "  graph [rankdir = TB, nodesep = 0.3, ranksep = 0.2, bgcolor = 'transparent']\n",
    sprintf("  node [shape = box, style = 'rounded,filled', fontname = 'Helvetica', fontsize = 15, width = %s, height = 0.55, penwidth = 1.4, margin = '0.4,0.08']\n", largura),
    "  edge [color = '#4a4a4a', arrowsize = 0.7, penwidth = 1.2, fontname = 'Helvetica', fontsize = 12]\n",
    paste(nos, collapse = "\n"), "\n",
    "  ", arestas, "\n",
    volta, "\n",
    "}\n"
  )

  DiagrammeR::grViz(dot, width = "100%", height = altura)
}

# Vários componentes que convergem para um resultado.
convergencia <- function(componentes, resultado,
                         cores = c("azul", "verde", "amarelo", "roxo",
                                   "turquesa", "coral"),
                         cor_resultado = "cinza", altura = 380) {
  k <- length(componentes)
  cores <- rep(cores, length.out = k)
  nos <- vapply(seq_len(k), function(i) {
    p <- paleta_livro[[cores[i]]]
    sprintf("  c%d [label = %s, fillcolor = '%s', color = '%s']",
            i, rotulo_no(componentes[i]), p[1], p[2])
  }, character(1))
  pr <- paleta_livro[[cor_resultado]]
  dot <- paste0(
    "digraph conv {\n",
    "  graph [rankdir = LR, nodesep = 0.12, ranksep = 1.0, bgcolor = 'transparent']\n",
    "  node [shape = box, style = 'rounded,filled', fontname = 'Helvetica', fontsize = 14, width = 2.6, height = 0.5, penwidth = 1.4, margin = '0.15,0.06']\n",
    "  edge [color = '#4a4a4a', arrowsize = 0.7, penwidth = 1.2]\n",
    paste(nos, collapse = "\n"), "\n",
    sprintf("  {rank = same; %s}\n", paste(sprintf("c%d", seq_len(k)), collapse = "; ")),
    sprintf("  r [label = %s, fillcolor = '%s', color = '%s', width = 2.4, height = 1, penwidth = 2]\n",
            rotulo_no(resultado), pr[1], "#5f7132"),
    paste(sprintf("  c%d -> r", seq_len(k)), collapse = "\n"), "\n",
    "}\n"
  )
  DiagrammeR::grViz(dot, width = "100%", height = altura)
}
