<%
/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<%@page import="com.liferay.portal.kernel.util.ParamUtil" %>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.liferay.portal.util.PortalUtil" %>
<%@ page import="java.io.BufferedWriter" %>
<%@page import="java.io.File"%>
<%@page import="java.io.FileNotFoundException"%>
<%@page import="java.io.FileWriter" %>
<%@page import="java.io.IOException" %>
<%@page import="java.io.BufferedWriter" %>
<%@page import="java.io.BufferedReader" %>
<%@page import="java.io.File"%>
<%@page import="java.io.DataInputStream"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.FileNotFoundException"%>
<%@page import="java.io.FileWriter" %>
<%@page import="java.io.IOException" %>
<%@page import="java.io.PrintWriter" %>
<%@page import="java.net.URL" %>
<%@page import="java.net.URLConnection" %>
<%@page import="java.text.DateFormat" %>
<%@page import="java.text.SimpleDateFormat" %>
<%@page import="java.util.Date" %>
<%@page import="java.util.GregorianCalendar" %>
<%@page import="java.util.Scanner" %>
<%@page import="javax.xml.parsers.DocumentBuilder" %>
<%@page import="javax.xml.parsers.DocumentBuilderFactory" %>
<%@page import="javax.xml.parsers.ParserConfigurationException" %>
<%@page import="org.w3c.dom.Document" %>
<%@page import="org.w3c.dom.Element" %>
<%@page import="org.w3c.dom.Node" %>
<%@page import="org.w3c.dom.NodeList" %>
<%@page import="org.xml.sax.SAXException" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %>
<%@ page import="javax.portlet.PortletURL" %>
<%@ page import="javax.portlet.PortletContext" %>
<portlet:defineObjects />

<liferay-theme:defineObjects />

<portlet:defineObjects />

<style type="text/css">
#map_canvas 
{
    height: 500px;

}

#panel_wu
{
   width:300px;
   
}

</style>
<script src="http://google-maps-utility-library-v3.googlecode.com/svn/trunk/markerclusterer/src/markerclusterer.js" type="text/javascript"></script>
<script src="http://www.basicslabs.com/Projects/progressBar/src/progressBar.js" type="text/javascript"></script>
<script type="text/javascript">

    var <portlet:namespace />map;
    var <portlet:namespace />geocoder;
    var <portlet:namespace />directionDisplay;
    var <portlet:namespace />directionsService;
    var pb;
 
    var  marker_wu= new Array();
    var marker_mtn= new Array();
    var visible_wu=false;
    var visible_mtn=false;
    var mcOptions = {gridSize: 50, maxZoom: 15};
    var markerCluster_wu;
    var markerCluster_mtn; 
    var <portlet:namespace />rendererOptions = {draggable :true };
    var <portlet:namespace />initialLocation;
    
    var hash=function(obj)
    {
    	return obj.getPosition().toString();
    	
    }
 
    function <portlet:namespace />initialize() 
    {
        var myLatlng = new google.maps.LatLng(-34.397, 150.644);
        var myOptions = {zoom : 6, center : myLatlng, mapTypeId : google.maps.MapTypeId.ROADMAP};
 
        <portlet:namespace />map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
        pb = new progressBar();
        <portlet:namespace />map.controls[google.maps.ControlPosition.RIGHT].push(pb.getDiv());
        <portlet:namespace />geocoder = new google.maps.Geocoder();
        <portlet:namespace />directionsService = new google.maps.DirectionsService();
        <portlet:namespace />directionsDisplay = new google.maps.DirectionsRenderer(<portlet:namespace />rendererOptions);
        <portlet:namespace />directionsDisplay.setMap(<portlet:namespace />map);
        <portlet:namespace />infowindow = new google.maps.InfoWindow();
 
        //geo location
        if (navigator.geolocation) 
        {
            browserSupportFlag = true;
            navigator.geolocation.getCurrentPosition(
            		function(position)
            		{
            			<portlet:namespace />initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
                        <portlet:namespace />map.setCenter(<portlet:namespace />initialLocation);

                    	<%
                        //recupero dati da Wunderground.com
                    	String [] weather_value_wu = new String[100000];
                    	String [] value_mtn= new String[100000];
                    	String [] mtn= new String[100000];
                        String [] city= new String [100000];
                        int count=0;
                        int count_mtn=0;
                        int countcity=0;
                        //File file = new File("/home/giacomo/Liferay/liferay-plugins-sdk-6.1.1/portlets/stazioni-portlet/docroot/city.txt");
                        File file = new File(getServletContext().getRealPath("/city.txt"));
                       
                        Scanner input = new Scanner(file);
                        
                        while(input.hasNext())
                        {
                            city[countcity] = input.nextLine();
                            countcity++;
                        }        
                        
                        count=0;
                        int j=0;
                     
                      //long startTime = System.currentTimeMillis();
                      //long endTime = System.currentTimeMillis();
                      //long t;

                      try
                      {
                        for(int i=0;i<countcity;i++)
                        {
                        	j=count;
                        	//URL googleWeatherXml = new URL("http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID="+city[i]);
                        	//URLConnection uc = googleWeatherXml.openConnection();
                        	//uc.connect();
                        	
                           //File fXmlFile=  new File("/home/giacomo/Liferay/liferay-plugins-sdk-6.1.1/portlets/stazioni-portlet/docroot/station/"+city[i]+".xml");
                        	File fXmlFile=  new File(getServletContext().getRealPath("/station/"+city[i]+".xml"));
                        	
                           DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                            DocumentBuilder db = dbf.newDocumentBuilder();
                            Document doc = db.parse(fXmlFile);
                          //Document doc = db.parse(uc.getInputStream());
                            doc.getDocumentElement().normalize(); 
                            NodeList nList = doc.getElementsByTagName("current_observation");    
                           
                            Node nNode = nList.item(0);
                           
                            if (nNode.getNodeType() == Node.ELEMENT_NODE ) 
                            {
                            	Element eElement = (Element) nNode;
                              
                             	weather_value_wu[j]=eElement.getElementsByTagName("latitude").item(0).getTextContent().toString();
                                weather_value_wu[j+1]=eElement.getElementsByTagName("longitude").item(0).getTextContent().toString();
                                weather_value_wu[j+2]=eElement.getElementsByTagName("temp_c").item(0).getTextContent().toString();
                                weather_value_wu[j+3]=eElement.getElementsByTagName("dewpoint_c").item(0).getTextContent().toString();
                                weather_value_wu[j+4]=eElement.getElementsByTagName("wind_mph").item(0).getTextContent().toString();
                                weather_value_wu[j+5]=eElement.getElementsByTagName("precip_today_metric").item(0).getTextContent().toString();
                                weather_value_wu[j+6]=eElement.getElementsByTagName("city").item(0).getTextContent().toString();
                                //weather_value_wu[j+7]=eElement.getElementsByTagName("city").item(0).getTextContent().toString();
                                weather_value_wu[j+7]=eElement.getElementsByTagName("relative_humidity").item(0).getTextContent().toString();
                                
                            }
                            
                            count=count+8;
                        }
                        }
                    
                        catch (Exception e)
                        {
                          System.err.println("Error: " + e.getMessage());
                        }
                        try
                        {
                            //FileInputStream fstream = new FileInputStream("/home/giacomo/Liferay/liferay-plugins-sdk-6.1.1/portlets/stazioni-portlet/docroot/mtn.txt");
                           FileInputStream fstream = new FileInputStream(getServletContext().getRealPath("/mtn.txt"));
                            
                            DataInputStream in = new DataInputStream(fstream);
                            BufferedReader br = new BufferedReader(new InputStreamReader(in));
                            String strLine;
                            int k=0;
                         
                            while ((strLine = br.readLine()) != null)   
                            {
                                String delims = "\t";
                                String[] tokens = strLine.split(delims);
                            
                                for (int i = 0; i < tokens.length; i++)
                                {
                                    value_mtn[k]=tokens[i];
                                    k++;
                                }
                                count_mtn++;
                            }
                  
                            in.close();
                            
                        }
                        
                        catch (Exception e)
                        {
                            System.err.println("Error: " + e.getMessage());
                        }

                        count=0;
                        for(int i=0;i<count_mtn;i++)
                        {
                        	j=count;
                        	//URL googleWeatherXml = new URL("http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID="+city[i]);
                        	//URLConnection uc = googleWeatherXml.openConnection();
                        	//uc.connect();
                        	
                            //File fXmlFile1=  new File("/home/giacomo/Liferay/liferay-plugins-sdk-6.1.1/portlets/stazioni-portlet/docroot/station/"+value_mtn[i*4]+".xml");
                        	File fXmlFile1=  new File(getServletContext().getRealPath("/station/"+value_mtn[i*4]+".xml"));
                            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                            DocumentBuilder db = dbf.newDocumentBuilder();
                            Document doc = db.parse(fXmlFile1);
                          //Document doc = db.parse(uc.getInputStream());
                            doc.getDocumentElement().normalize(); 
                            NodeList nList = doc.getElementsByTagName("getRealtimeStationLastData");    
                            Node nNode = nList.item(0);

                        	Element eElement = (Element) nNode;
                           
                           	if (nNode.getNodeType() == Node.ELEMENT_NODE) 
                            {
                           		if(eElement.getElementsByTagName("status")!=null && eElement.getElementsByTagName("status").item(0).getTextContent().compareTo("1")!=0)
                                {
                           			mtn[j]="none";
                          	        mtn[j+1]="none";
                          	        mtn[j+2]="none";
                          	        mtn[j+3]="none";
                          	        
                                }
                           	    else
                           	    {
                             	    mtn[j]=eElement.getElementsByTagName("temperature").item(0).getTextContent().toString();
                             	    mtn[j+1]=eElement.getElementsByTagName("wind_speed").item(0).getTextContent().toString();
                             	    mtn[j+2]=eElement.getElementsByTagName("rain_rate").item(0).getTextContent().toString();
                             	    mtn[j+3]=eElement.getElementsByTagName("dew_point").item(0).getTextContent().toString();
                             	}
                          
                           	 }
                           	
                            count=count+4;
                            
                        }
                   
                        %>
                      
                        
                        var city_wu= new Array();
                        var latitude_wu= new Array();
                        var longitude_wu= new Array();
                        var temp_wu= new Array();
                        var dew_wu= new Array();
                        var wind_wu= new Array();
                        var precipitazioni_wu= new Array();
                        // var url_wu= new Array();
                        var hum_wu= new Array();
                        
                        var id_mtn= new Array();
                        var city_mtn= new Array();
                        var latitude_mtn= new Array();
                        var longitude_mtn= new Array();
                        var temperature_mtn= new Array();
                        var wind_mtn= new Array();
                        var rain_mtn= new Array();
                        var dew_mtn= new Array();
                        <portlet:namespace />map.controls[google.maps.ControlPosition.RIGHT].push(pb.getDiv());
                        
                        
                        <% for (int i=0; i<count_mtn; i++) 
                        { %>
                            id_mtn[<%= i %>] ="<%= value_mtn[i*4] %>"
                        	city_mtn[<%= i %>] ="<%= value_mtn[i*4+3] %>";
                         	latitude_mtn[<%= i %>]="<%= value_mtn[i*4+1] %>";
                         	longitude_mtn[<%= i %>]="<%=  value_mtn[i*4+2] %>";
                            temperature_mtn[<%= i %>] ="<%= mtn[i*4] %>";
                            wind_mtn[<%= i %>] ="<%= mtn[i*4+1] %>";
                            rain_mtn[<%= i %>] ="<%= mtn[i*4+2] %>";
                            dew_mtn[<%= i %>] ="<%= mtn[i*4+3] %>" ;
                         	<% 
                        }%>
                        
                        <% for (int i=0; i<countcity; i++) 
                        { %>
                        	city_wu[<%= i %>] ="<%= weather_value_wu[i*8+6] %>";
                         	latitude_wu[<%= i %>]="<%= weather_value_wu[i*8+0] %>";
                         	longitude_wu[<%= i %>]="<%=  weather_value_wu[i*8+1] %>";
                         	temp_wu[<%= i %>]="<%= weather_value_wu[i*8+2] %>";
                         	dew_wu[<%= i %>]="<%= weather_value_wu[i*8+3] %>";
                         	wind_wu[<%= i %>]="<%= weather_value_wu[i*8+4] %>";
 							precipitazioni_wu[<%= i %>]="<%= weather_value_wu[i*8+5] %>";
                         	hum_wu[<%= i %>]="<%= weather_value_wu[i*8+7] %>";
                         	<% 
                        }%>
                         
                        var infowindow_wu=new Array();
                        var infowindow_mtn=new Array();
                    	var contentString_wu=new Array();
                     	var contentString_mtn=new Array();
                    	var last=null;
                    	var last_mtn=null;
                        markerCluster_wu=new MarkerClusterer(<portlet:namespace />map,[],mcOptions);
                        markerCluster_mtn=new MarkerClusterer(<portlet:namespace />map,[],mcOptions);
                        

	                   //var image=new Array();
	                   
	                    for (var i = 0; i < <%= count_mtn %>; i++) 
                        {
                        	
	                    	//image[i]=new google.maps.MarkerImage(
                            //	url[i],
                    	   //  null, /* size is determined at runtime */
                    		    //null, /* origin is 0,0 */
                    		    //null, /* anchor is bottom center of the scaled image */
                    		   // new google.maps.Size(32, 32));   
                    	
                    		marker_mtn[i]= new google.maps.Marker({
                            map : <portlet:namespace />map,
                            animation: google.maps.Animation.DROP,
                            clickable:true,
                            position : new google.maps.LatLng(latitude_mtn[i], longitude_mtn[i]),
                            icon: "http://portal.drihm.eu/kml/mtn.png"
                            });
                    		marker_mtn[i].setVisible(false);
                    	
                    		//markerCluster_mtn.addMarker(marker_mtn[i]);
                    		//markerCluster_mtn.clearMarkers();   
                    		
                    		contentString_mtn[i] ='<div id="content">'+ '<table border="0">'+
                            '<tr>'+
                         	'<td align="left"style="font-size:20px"> <b>'+city_mtn[i]+'</b></td>'+ '<td ></td>'+
                            '</tr>'+
                            '<tr>'+
                    	    '<td align="left" style="font-size:20px">'+temperature_mtn[i]+'� C</td>'+
                    	    '<td align="right"> </td>'+
                    	    '</tr>'+
                            '<tr>'+
                     	    '<td>Dewpt: '+dew_mtn[i]+'� C</td>'+
                     	  
                 		    '</tr>'+
                 		    '<tr>'+
                 		    '<td align="left">Wind: '+wind_mtn[i]+' mph </td>'+
                 		    '<td align="right">Precip.: '+rain_mtn[i]+' cm</td>'+
             			    '</tr>'+
             			    '<tr>'+'<td>Powered by <a href="http://www.meteonetwork.it/" target="_blank"> meteonetwork.it </a></td>'+'</tr>'+
                            '</table>'+'</div>';
                            
                            infowindow_mtn[hash(marker_mtn[i])]=new google.maps.InfoWindow({content: contentString_mtn[i]  });
                          
                    	    google.maps.event.addListener(marker_mtn[i], 'click', function() {
                    	    if ((last_mtn!=null && last!=null)|| last_mtn!=null )
                    	    {
                    	    	infowindow_mtn[last_mtn].close();
                    	    	if (last!=null)
                    	    		infowindow_wu[last].close();
                    	    }
                    	    infowindow_mtn[hash(this)].open(<portlet:namespace />map,this);
                            last_mtn=hash(this);
                            });
                    	 }
                       
                        for (var i = 0; i < <%= countcity %>; i++) 
                        {
                        	//image[i]=new google.maps.MarkerImage(
                            //	url[i],
                    	   //  null, /* size is determined at runtime */
                    		    //null, /* origin is 0,0 */
                    		    //null, /* anchor is bottom center of the scaled image */
                    		   // new google.maps.Size(32, 32));   
                    	
                    		marker_wu[i]= new google.maps.Marker({
                            map : <portlet:namespace />map,
                            animation: google.maps.Animation.DROP,
                            clickable:true,
                            position : new google.maps.LatLng(latitude_wu[i], longitude_wu[i]),
                            icon: "http://portal.drihm.eu/kml/wu.png"
                            });
                    	
                    		marker_wu[i].setVisible(false);
                    		//markerCluster_wu.addMarker(marker_wu[i]);
                    		//markerCluster_wu.clearMarkers();
                    		
                    		contentString_wu[i] ='<div id="content">'+ '<table border="0">'+
                            '<tr>'+
                         	'<td align="left"style="font-size:20px"> <b>'+city_wu[i]+'</b></td>'+ '<td ></td>'+
                            '</tr>'+
                            '<tr>'+
                    	    '<td align="left" style="font-size:20px">'+temp_wu[i]+'� C</td>'+
                    	    '<td align="right"> </td>'+
                    	    '</tr>'+
                            '<tr>'+
                     	    '<td>Dewpt: '+dew_wu[i]+'� C</td>'+
                     	    '<td  align="right">Hum: '+hum_wu[i]+' %</td>'+
                 		    '</tr>'+
                 		    '<tr>'+
                 		    '<td align="left">Wind: '+wind_wu[i]+' mph </td>'+
                 		    '<td align="right">Precip.: '+precipitazioni_wu[i]+'</td>'+
             			    '</tr>'+
             			    '<tr>'+'<td>Powered by <a href="http://www.wunderground.com/" target="_blank"> wunderground.com </a></td>'+'</tr>'+
                            '</table>'+'</div>';
                            
                            infowindow_wu[hash(marker_wu[i])]=new google.maps.InfoWindow({content: contentString_wu[i]  });
                          
                    	    google.maps.event.addListener(marker_wu[i], 'click', function() {
                    	    if ((last_mtn!=null && last!=null)|| last!=null)
                    	    {
                    	    	infowindow_wu[last].close();
                    	    	if (last_mtn!=null)
                    	    		infowindow_mtn[last_mtn].close();
                    	    }
                    	    infowindow_wu[hash(this)].open(<portlet:namespace />map,this);
                            last=hash(this);
                            });
                    	 }
                       
                       
                        
            		},
            		
                    function() {<portlet:namespace />handleNoGeolocation(browserSupportFlag);});
        }  
        else 
        {
            // Browser doesn't support Geolocation
            browserSupportFlag = false;
            <portlet:namespace />handleNoGeolocation(browserSupportFlag);
        }
        
    }
    
    function load_wu()
    {
    	if (visible_wu==false)
    		pb.start(marker_wu.length);
    	
        setTimeout('clearMarkers_wu()', 1);
      setTimeout('pb.hide()', 55000);
    	
    }
    

    // Removes the markers from the map, but keeps them in the array.
	function clearMarkers_wu() 
    {
		
    	if(visible_wu==true)
	    	{
	    		for (var i = 0; i < marker_wu.length; i++) 
	    			marker_wu[i].setVisible(false);
	    		
	    		markerCluster_wu.clearMarkers();
	    		visible_wu=false;
	    		}
	    	else
	    	{
	    		for (var i = 0; i < marker_wu.length; i++)
	    		{
	    			marker_wu[i].setVisible(true);
	    		    markerCluster_wu.addMarker(marker_wu[i]);
	    		    pb.updateBar(1);
	    		}
	    		visible_wu=true;
	    		
	    	}
    
	}
    
	function clearMarkers_mtn() 
    {
	    	if(visible_mtn==true)
	    	{
	    		for (var i = 0; i < marker_mtn.length; i++) 
	    			marker_mtn[i].setVisible(false);
	    		
	    		markerCluster_mtn.clearMarkers();
	    		visible_mtn=false;
	    		}
	    	else
	    	{
	    		for (var i = 0; i < marker_mtn.length; i++)
	    		{
	    			
	    			marker_mtn[i].setVisible(true);
	    		    markerCluster_mtn.addMarker(marker_mtn[i]);
	    		}
	    		visible_mtn=true;
	    	}
	}
	 
 
    function <portlet:namespace />handleNoGeolocation(errorFlag) 
    {
        if (errorFlag == true) 
        {
            <portlet:namespace />initialLocation = null;
            contentString = "Error: The Geolocation service failed.";
        } 
        else 
        {
            <portlet:namespace />initialLocation = null;
            contentString = "Error: Your browser doesn't support geolocation. Are you in Siberia?";
        }
        <portlet:namespace />map.setCenter(<portlet:namespace />initialLocation);
        <portlet:namespace />infowindow.setContent(contentString);
        <portlet:namespace />infowindow.setPosition(<portlet:namespace />initialLocation);
        <portlet:namespace />infowindow.open(<portlet:namespace />map);
    }
    
  
    function <portlet:namespace />loadScript() 
    {
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.src = "http://maps.google.com/maps/api/js?libraries=drawing&sensor=false&callback=<portlet:namespace />initialize";
        document.body.appendChild(script);
        
    }
    
       
    window.onload = <portlet:namespace />loadScript;    
    

    
</script>
 	
<liferay-ui:tabs
	names="Weather Station"
	refresh="<%=false %>">
	<liferay-ui:section >
	<body>
    <div id="panel_wu">
      <input type="checkbox" onclick="clearMarkers_mtn();" name="option1" value="meteonetwork.it"> meteonetwork.it <img src="http://portal.drihm.eu/kml/mtnlogo.png" style="max-height: 100px; max-width: 100px;"/><br>
      <input type="checkbox" onclick="load_wu();" name="option2" value="wunderground.com"> wunderground.com <img src="http://portal.drihm.eu/kml/wulogo.png" style="max-height: 100px; max-width: 100px;"/><br>
    </div>
		<div id="map_canvas" class="w100 bluborder" style="display: block;"></div>
    </liferay-ui:section>

</liferay-ui:tabs>
    
    
	

