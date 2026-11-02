# Tema e paleta comuns para as figuras de dados do livro (ggplot2).
# Uso nos capítulos: source("R/graficos.R") em um bloco com include: false.

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
})

verde_livro <- "#5f7132"

# Paleta qualitativa acessível (Okabe–Ito)
okabe <- c("#0072B2", "#D55E00", "#009E73", "#E69F00", "#CC79A7",
           "#56B4E9", "#F0E442", "#000000")

theme_livro <- function(base_size = 13) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      plot.title = element_text(face = "bold", size = rel(0.95)),
      plot.subtitle = element_text(colour = "grey35", size = rel(0.85)),
      strip.text = element_text(face = "bold"),
      legend.position = "bottom",
      axis.title = element_text(colour = "grey25")
    )
}

# Média e intervalo de confiança de 95% (t) para stat_summary(), sem depender do Hmisc.
media_ic95 <- function(y) {
  y <- y[!is.na(y)]
  m <- mean(y)
  e <- qt(0.975, length(y) - 1) * sd(y) / sqrt(length(y))
  data.frame(y = m, ymin = m - e, ymax = m + e)
}

# Desenha uma tabela como grade de células coloridas.
#   df:    data.frame com os valores (já como texto)
#   papel: vetor nomeado (um por coluna) com o papel da coluna, usado na cor
#   cores: vetor nomeado papel -> cor
tabela_grade <- function(df, papel, cores, titulo = NULL, tam = 3.6,
                         legenda = TRUE) {
  nr <- nrow(df); nc <- ncol(df)
  cel <- expand.grid(linha = seq_len(nr), coluna = seq_len(nc))
  cel$texto <- mapply(function(i, j) as.character(df[i, j]), cel$linha, cel$coluna)
  cel$papel <- papel[names(df)][cel$coluna]
  cab <- data.frame(linha = 0, coluna = seq_len(nc), texto = names(df),
                    papel = papel[names(df)])
  ggplot() +
    geom_tile(data = cel, aes(coluna, -linha, fill = papel),
              colour = "white", linewidth = 1, alpha = 0.45) +
    geom_tile(data = cab, aes(coluna, -linha, fill = papel),
              colour = "white", linewidth = 1) +
    geom_text(data = cel, aes(coluna, -linha, label = texto), size = tam) +
    geom_text(data = cab, aes(coluna, -linha, label = texto),
              size = tam, fontface = "bold", colour = "white") +
    scale_fill_manual(values = cores, limits = names(cores), name = NULL,
                      guide = if (legenda) "legend" else "none") +
    coord_fixed(ratio = 0.45, clip = "off") +
    labs(title = titulo) +
    theme_void(base_size = 13) +
    theme(legend.position = "bottom",
          plot.title = element_text(face = "bold", size = rel(0.95),
                                    hjust = 0.5))
}
