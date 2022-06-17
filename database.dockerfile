FROM mcr.microsoft.com/mssql/server:2019-latest

#Setup Enviroment Variables
ENV ACCEPT_EULA="Y"
ENV SA_PASSWORD="Merlin123"


#Default to root user
USER root

#Install the ability to use envsubst to replace env into files
RUN apt-get -y update &&\
    apt-get install -y gettext-base

#Create Folder
RUN mkdir -p /usr/src/

#Working Directory
WORKDIR /usr/src/

#Copy all Database Files
COPY database /usr/src/

#Setup the database
RUN /usr/src/setup.sh