FROM ubuntu:trusty

ARG DEBIAN_FRONTED='noninteractive'

RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8



## Install some useful tools and dependencies for MRO
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
        wget \
	&& rm -rf /var/lib/apt/lists/*


WORKDIR /home/docker

# Download, valiate, and unpack and install Micrisift R open
RUN wget  https://www.dropbox.com/s/xrkzdhm1cq0ll1q/microsoft-r-open-3.3.2.tar.gz?dl=1 -O microsoft-r-open-3.3.2.tar.gz \
&& echo "817aca692adffe20e590fc5218cb6992f24f29aa31864465569057534bce42c7 microsoft-r-open-3.3.2.tar.gz" > checksum.txt \
    && sha256sum -c --strict checksum.txt \
    && tar -xf microsoft-r-open-3.3.2.tar.gz \
    && cd /home/docker/microsoft-r-open \
    && ./install.sh -a -u \
    && ls logs && cat logs/*


# Clean up
WORKDIR /home/docker
RUN rm microsoft-r-open-3.3.2.tar.gz \
	&& rm checksum.txt \
&& rm -r microsoft-r-open

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    libxml2-dev \
    libssl-dev

# system library dependency for the euler app
RUN apt-get update && apt-get install -y \
    libmpfr-dev \
    gfortran \
    aptitude \
    libgdal-dev \
    libproj-dev \
    g++ \
    libicu-dev \
    libpcre3-dev\
    libbz2-dev \
    liblzma-dev \
    openjdk-7-jdk \
    libnlopt-dev \
    build-essential

COPY Makeconf /usr/lib64/microsoft-r/3.3/lib64/R/etc/Makeconf

#RUN sudo R CMD javareconf


# basic shiny functionality
RUN  R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')" \
RUN R -e "install.packages(c('shiny'), repos='http://cran.rstudio.com/')" \
&& R -e "install.packages('binom', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('dplyr', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('purrr', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('ggplot2', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('reshape', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('curl', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('httr', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('devtools', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('formattable', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('car', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('fmsb', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('igraph', repos='https://cran.r-project.org/')" \
&& sudo su - -c "R -e \"install.packages('miniUI', repos='https://cran.r-project.org/');options(unzip = 'internal'); devtools::install_github('daattali/shinyjs')\"" \
#RUN R -e "options(unzip = 'internal'); devtools::install_github('daattali/shinyjs')" \
&& R -e "install.packages('scales', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('crosstalk', repos='https://cran.r-project.org/')" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('rstudio/DT')\"" \
#RUN R -e "devtools::install_github('rstudio/DT')" \
&& sudo su - -c "R -e \"install.packages(c('raster', 'sp', 'viridis'), repos='https://cran.r-project.org/');options(unzip = 'internal'); devtools::install_github('rstudio/leaflet')\"" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('bhaskarvk/leaflet.extras')\"" \
&& R -e "install.packages('ggrepel', repos='https://cran.r-project.org/')" \
#RUN R -e "install.packages('leaflet', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('visNetwork', repos='https://cran.r-project.org/')" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('kuzmenkov111/highcharter')\"" \
#&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_version('highcharter', version = '0.5.0', repos = 'https://cran.r-project.org/')\"" \
#RUN R -e "download.file(url = 'http://cran.r-project.org/src/contrib/Archive/highcharter/highcharter_0.3.0.tar.gz', destfile = 'highcharter_0.3.0.tar.gz')"
#RUN R -e "install.packages(pkgs='highcharter_0.3.0.tar.gz', type='source', repos=NULL)"
#RUN R -e "unlink('highcharter_0.3.0.tar.gz')"
&& R -e "install.packages('shinyBS', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('data.table', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('maptools', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('rgdal', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('googleVis', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('future', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('tidyr', repos='https://cran.r-project.org/')"\
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('daattali/timevis')\""\
&& R -e "install.packages('shinythemes', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('formattable', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('fst', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('leaflet.minicharts', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('RColorBrewer', repos='https://cran.r-project.org/')" \ 
&& R -e "install.packages('shinyWidgets', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('shinyjqui', repos='https://cran.r-project.org/')"  \
&& R -e "install.packages('collapsibleTree', repos='https://cran.r-project.org/')"  \
#&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('kuzmenkov111/shinyURL')\"" \
&& R -e "install.packages('RCurl', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('shinycssloaders', repos='https://cran.r-project.org/')" \
#&& sudo R -e "install.packages('ReporteRs', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('officer', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('flextable', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('raster', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('digest', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('bcrypt', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('radarchart', repos='https://cran.r-project.org/')" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('hrbrmstr/qrencoder')\""

COPY Rprofile.site /usr/lib64/microsoft-r/3.3/lib64/R/etc/



EXPOSE 3838

CMD ["R", "-e shiny::runApp('/root/monap')"]

