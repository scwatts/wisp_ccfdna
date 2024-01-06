FROM docker.io/continuumio/miniconda3:23.10.0-1

RUN \
  conda install -y -n base conda-libmamba-solver && \
  conda config --set solver libmamba && \
  conda install -y -c bioconda -c conda-forge -c conda \
    bioconductor-copynumber 'openjdk >=8' r-dplyr && \
  conda clean -yaf

RUN \
  mkdir -p /opt/cobalt/ && \
  wget -O /opt/cobalt/cobalt.jar 'https://github.com/hartwigmedical/hmftools/releases/download/cobalt-v1.16.rc1/cobalt_v1.16.rc1.jar'
