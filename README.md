**first draft


sudo docker run --rm -it -p 8080:8080 geobricks/geoserver:0.1
sudo docker run -v /external_data_dir/:/geoserver/data/:rw  --rm -it -p 8080:8080 geobricks/geoserver:0.1

n.b. GEOSERVER_DATA_DIR = /geoserver/data has to be mapped in 