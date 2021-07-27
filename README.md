# capetown_clinic_access

## OSRM processing

```bash
docker pull osrm/osrm-backend
```

```bash
docker run -t -v "${PWD}/osrm_data:/data" osrm/osrm-backend osrm-extract -p /opt/foot.lua /data/map.xml
docker run -t -v "${PWD}/osrm_data:/data" osrm/osrm-backend osrm-contract /data/map.xml.osrm
```


``bash
docker run -t -i -p 5000:5000 -v "${PWD}/osrm_data:/data" osrm/osrm-backend osrm-routed /data/map.xml.osrm
```
