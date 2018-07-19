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
RUN wget https://www.dropbox.com/s/k42g2ra7ll46omp/microsoft-r-open-3.5.0.tar.gz?dl=1 -O microsoft-r-open-3.5.0.tar.gz \
&& echo "7E1091587429C1545804B514269F4B0C588B85EC86052B512AAFD491DB797D93 microsoft-r-open-3.5.0.tar.gz" > checksum.txt \
	&& sha256sum -c --strict checksum.txt \
	&& tar -xf microsoft-r-open-3.5.0.tar.gz \
	&& cd /home/docker/microsoft-r-open \
	&& ./install.sh -a -u \
	&& ls logs && cat logs/*


# Clean up
WORKDIR /home/docker
RUN rm microsoft-r-open-3.5.0.tar.gz \
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

#COPY Makeconf /usr/lib64/microsoft-r/3.3/lib64/R/etc/Makeconf

RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
RUN apt-get update
RUN apt-get install -y libudunits2-dev libgdal-dev libgeos-dev 


RUN sudo apt-add-repository -y ppa:webupd8team/java \
&& apt-get update && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && apt-get install -y oracle-java8-installer \
&& R -e "Sys.setenv(JAVA_HOME = '/usr/lib/jvm/java-8-oracle/jre')"
RUN sudo java -version

#RUN sudo R CMD javareconf
RUN sudo apt-get install -y ncbi-blast+

# basic shiny functionality
RUN sudo R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')" \
&& R -e "install.packages(c('shiny'), repos='http://cran.rstudio.com/')" \
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
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('hrbrmstr/qrencoder')\""\
&& R -e "source('https://bioconductor.org/biocLite.R'); biocLite(); biocLite('Biostrings')" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('kuzmenkov111/rBLAST')\"" \
&& R -e "install.packages('msaR', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('RColorBrewer', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('stringi', repos='https://cran.r-project.org/')" \
&& R CMD javareconf \
&& R -e "Sys.setenv(JAVA_HOME = '/usr/lib/jvm/java-8-oracle/jre'); install.packages('rJava', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('mailR', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('RPostgres', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('stringi', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('pool', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('DBI', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('GoodmanKruskal', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('rjson', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('uuid', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('stringr', repos='https://cran.r-project.org/')" \
&& R -e "install.packages('shinytoastr', repos='https://cran.r-project.org/')" \
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('ropensci/plotly')\""\
&& sudo su - -c "R -e \"options(unzip = 'internal'); devtools::install_github('stefanedwards/lemon')\""\
&& sudo su - -c "R -e \"options(unzip = 'internal');  devtools::install_github('emitanaka/shinycustomloader')\"" 


COPY Rprofile.site /usr/lib64/microsoft-r/3.3/lib64/R/etc/



EXPOSE 3838

CMD ["R", "-e shiny::runApp('/root/monap')"]

