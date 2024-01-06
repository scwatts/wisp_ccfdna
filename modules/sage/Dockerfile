FROM docker.io/continuumio/miniconda3:23.10.0-1

RUN \
  conda install -y -n base conda-libmamba-solver && \
  conda config --set solver libmamba && \
  conda install -y -c bioconda -c conda-forge -c conda \
    'bcftools ==1.16' \
    bioconductor-genomicranges \
    bioconductor-variantannotation \
    font-ttf-dejavu \
    'openjdk >=8' \
    r-dplyr \
    r-ggplot2 \
    r-tidyr \
    xorg-libxt \
    zlib && \
  conda clean -yaf

RUN \
  mkdir -p /opt/sage/ && \
  wget -O /opt/sage/sage.jar 'https://github.com/hartwigmedical/hmftools/releases/download/sage-v3.4.rc1/sage_v3.4.rc1.jar'
