FROM docker.io/continuumio/miniconda3:23.10.0-1

RUN \
  conda install -y -n base conda-libmamba-solver && \
  conda config --set solver libmamba && \
  conda install -y -c bioconda -c conda-forge -c conda \
    'r-base ==4.2.2' 'r-tidyverse' 'openjdk >=8' && \
  conda clean -yaf

RUN \
  mkdir -p /opt/wisp/ && \
  wget -O /opt/wisp/wisp.jar 'https://github.com/hartwigmedical/hmftools/releases/download/wisp-v1.1.rc1/wisp_v1.1.rc1.jar'
