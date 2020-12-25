this.Openlayers_Map=function(){function r(e,t){null==t&&(t={}),this.canvas=e,this.opts=t,this.opts.zoom||(this.opts.zoom=r.defaultZoom),this.markerFeature=null,this.markerLayer=null,this.popup=null,this.markerIcon="/assets/img/map-marker.png",this.render()}return r.defaultZoom=10,r.prototype.render=function(){return this.initMap(),this.initPopup(),this.opts.markers&&this.renderMarkers(this.opts.markers),this.resize(),this.renderEvents()},r.prototype.createLayers=function(e){var t,r,o,a,n,i,s,p;for(o=[],t=0,a=e.length;t<a;t++)s=(n=e[t]).source,p=n.url,i=n.projection,r=new ol.layer.Tile({source:new ol.source[s]({url:p,projection:i})}),o.push(r);return o},r.prototype.initMap=function(){var e,t;return e=this.opts.center||[138.252924,36.204824],(t=this.opts.layers)||(t=[{source:"XYZ",url:"https://cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png",projection:"EPSG:3857"}]),this.map=new ol.Map({target:this.canvas,renderer:["canvas","dom"],layers:this.createLayers(t),controls:ol.control.defaults({attributionOptions:{collapsible:!1}}),view:new ol.View({projection:"EPSG:3857",center:ol.proj.transform(e,"EPSG:4326","EPSG:3857"),maxZoom:18,zoom:this.opts.zoom}),logo:!0})},r.prototype.initPopup=function(){var o,e;return $("body").append('<div id="marker-popup"><div class="closer"></div><div class="content"></div></div>'),this.popup=$("#marker-popup"),this.popup.hide(),this.popupOverlay=new ol.Overlay({element:this.popup.get(0),autoPan:!0,autoPanAnimation:{duration:250}}),this.map.addOverlay(this.popupOverlay),this.map.on("pointermove",(o=this,function(e){var t,r;if(!e.dragging)return r=o.map.getEventPixel(e.originalEvent),t=o.map.hasFeatureAtPixel(r)?"pointer":"",o.map.getTarget().style.cursor=t;o.popup.hide()})),this.popup.find(".closer").on("click",(e=this,function(){return e.popupOverlay.setPosition(void 0),$(e).blur(),!1}))},r.prototype.showPopup=function(e,t){var r;if(r=e.get("markerHtml"))return this.popup.find(".content").html(r),this.popup.show(),this.popupOverlay.setPosition(t);this.popup.hide()},r.prototype.renderEvents=function(){return this.map.on("click",(r=this,function(e){var t;(t=r.map.forEachFeatureAtPixel(e.pixel,function(e){return e}))&&r.showPopup(t,e.coordinate)}));var r},r.prototype.createMarkerStyle=function(e){return new ol.style.Style({image:new ol.style.Icon({anchor:[.5,1],anchorXUnits:"fraction",anchorYUnits:"fraction",src:e})})},r.prototype.setMarker=function(e,t){var r,o,a,n,i,s,p;return null==t&&(t={}),o=this.markerIcon,t.image&&(o=t.image),p=this.createMarkerStyle(o),a=[e[1],e[0]],(r=new ol.Feature({geometry:new ol.geom.Point(ol.proj.transform(a,"EPSG:4326","EPSG:3857")),markerId:null!=(n=t.id)?n:null,markerHtml:null!=(i=t.html)?i:null,category:null!=(s=t.category)?s:null,iconSrc:o})).setStyle(p),this.markerLayer?this.markerLayer.getSource().addFeature(r):(this.markerLayer=new ol.layer.Vector({source:new ol.source.Vector({features:[r]})}),this.map.addLayer(this.markerLayer)),r},r.prototype.getMarker=function(t){var r;return r=null,this.markerLayer&&this.markerLayer.getSource().forEachFeature(function(e){if(e.get("markerId")===t)return r=e}),r},r.prototype.getMarkers=function(){return this.markerLayer.getSource().getFeatures()},r.prototype.removeMarkers=function(){var t;this.popup&&this.popup.hide(),this.markerLayer&&(t=this.markerLayer.getSource()).forEachFeature(function(e){t.removeFeature(e)})},r.prototype.setCenter=function(e){return this.map.getView().setCenter(ol.proj.transform(e,"EPSG:4326","EPSG:3857"))},r.prototype.setZoom=function(e){return this.map.getView().setZoom(e)},r.prototype.renderMarkers=function(e){var t,r,o,a,n,i,s,p,u,l,c,h,m;for(c=[],o=0;o<e.length;o++)r="/assets/img/map-marker.png",(a=e[o]).image&&(r=a.image),h=this.createMarkerStyle(r),n="",i=a.name,m=a.text,i&&(n+="<p>"+i+"</p>"),m&&$.each(m.split(/[\r\n]+/),function(){return this.match(/^https?:\/\//)?n+='<p><a href="'+this+'">'+this+"</a></p>":n+="<p>"+this+"</p>"}),s=[a.loc[1],a.loc[0]],(t=new ol.Feature({geometry:new ol.geom.Point(ol.proj.transform(s,"EPSG:4326","EPSG:3857")),markerId:null!=(p=a.id)?p:o,markerHtml:null!=(u=a.html)?u:n,category:null!=(l=a.category)?l:null,iconSrc:r})).setStyle(h),this.markerLayer?c.push(this.markerLayer.getSource().addFeature(t)):(this.markerLayer=new ol.layer.Vector({source:new ol.source.Vector({features:[t]})}),c.push(this.map.addLayer(this.markerLayer)));return c},r.prototype.resize=function(){var e;this.markerLayer&&(e=this.markerLayer.getSource().getExtent(),this.map.getView().fit(e,this.map.getSize()),this.map.getView().getZoom()>this.opts.zoom&&this.map.getView().setZoom(this.opts.zoom))},r.prototype.loadLayer=function(n,e){var i=this,s=n,p=e,u=new ol.source.Vector({format:new p,loader:function(t,e,r){r.getCode();var o=new XMLHttpRequest,a=function(){console.log("loadLayer error:"+n)};o.open("GET",s),o.onerror=a,o.onloadstart=function(){$(i.canvas).hide()},o.onload=function(){if(200==o.status){var e=(new p).readFeatures(o.responseText,{featureProjection:r});u.addFeatures(e),t=l.getSource().getExtent(),$(i.canvas).show(),i.map.getView().fit(t,i.map.getSize()),i.map.getView().getZoom()>i.opts.zoom&&i.map.getView().setZoom(i.opts.zoom)}else a()},o.send()}}),l=new ol.layer.Vector({map:this.map,source:u})},r}();