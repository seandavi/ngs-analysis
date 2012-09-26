<html>
    <head>
        <title>Fastq QC Report</title>
        <style type="text/css">
		@page {
  			size: letter;
		  	margin-left: 1.5cm;
			margin-right: 1.5cm;
			margin-top: 1.7cm;
			@frame header { 
				-pdf-frame-content: headerContent; 
				top: .5cm; 
				margin-left: 1cm; 
				margin-right: 1cm; 
				margin-bottom: 1cm; 
				height: 10cm; 
                	}
			@frame footer {
				-pdf-frame-content: footerContent;
				bottom: 1cm;
				margin-left: 1cm;
				margin-right: 1cm;
			  	height: 1cm;
  			}
		}
		@page innerPage{
  			size: letter;
		  	margin: 1cm;
			margin-top: 1.7cm;
			@frame header { 
				-pdf-frame-content: headerContent; 
				top: .5cm; 
				margin-left: 1cm; 
				margin-right: 1cm; 
				margin-bottom: 1cm; 
				height: 10cm; 
                	}
			@frame footer {
				-pdf-frame-content: footerContent;
				bottom: 1cm;
				margin-left: 1cm;
				margin-right: 1cm;
			  	height: 1cm;
  			}
		}
		body {
			margin: 0px;
			padding: 0px;
			color: #333300;
			font-family: Verdana, Arial, Helvetica;
		}
		#headerContent {
			font-size: 11px;
			font-style: italic;
			color: #999999;
		}
		#footerContent {
			font-size: 11px;
			text-align: center;
		}
		pdftoc {
		}
		pdftoc.pdftoclevel0 {
			font-weight: bold;
			font-size: 13px;
			margin-left: 1em;
			margin-top: 0.5em;
		}
		pdftoc.pdftoclevel1 {
			font-weight: normal;
			margin-left: 1.5em;
		}
		pdftoc.pdftoclevel2 {
			margin-left: 2em;
			font-style: italic;
		}

		body table {
			margin: 0px;
			padding: 0px;
		}
		body th {
			text-align: left;
			margin: 0px;
			padding: 0px 2px 0px 2px;
			vertial-align: bottom;
			border: none;
		}
		body td {
			margin: 0px;
			padding: 3px 2px 0px 2px;
			vertial-align: bottom;
			border: 1px solid #EFEFEF;
		}
		.report-title {
			font-size: 26px;
			margin: 0px;
			padding: 0px;
		}
		.report-title-sub {
			font-size: 22px;
			margin: 0px;
			padding: 0px;
		}
		.image-title {
			font-size: 14px;
			color: #666666;
			font-weight: normal;
		}
        </style>
    </head>
    <body>

	<!-- [ Template header and footer ] -->
	<div id="headerContent">
		<p>{{ company }} NGS Services</p>
	</div>
        <div id="footerContent">
		<pdf:pagenumber>
        </div>


	<!-- [ Title page ] -->
	<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
	<p class='report-title'> {{ company }} </p>
	<p class='report-title-sub'>Sequence QC Report </p>


	<!-- [ Table of contents ] -->
	<pdf:nexttemplate name="innerPage">
	<pdf:nextpage>
	<p style='font-size: 14px; font-weight: bold;'> Table of Contents <p>
	<div>
	<pdf:toc>
	</div>

	<!-- [ Basic information summary page ] -->
	<pdf:nextpage>
	<h1> Basic Information </h1>
	<h2> Files </h2>
	<table>
		<tr><th> Filename          </th><th> File size </th></tr>
		{% for sample in samples %}
		<tr><td> {{ data|keyval:sample|keyval:"Filename"|keyval:"R1" }} </td>
		    <td> {{ data|keyval:sample|keyval:"Filesize"|keyval:"R1" }} </td></tr>
		<tr><td> {{ data|keyval:sample|keyval:"Filename"|keyval:"R2" }} </td>
		    <td> {{ data|keyval:sample|keyval:"Filesize"|keyval:"R2" }} </td></tr>
		{% endfor %}
	</table>

	<br /><br />
	<h2> Quality Summary </h2>
	{% for sample in samples %}
	<h2> Sample: {{ sample }} </h2>
	<table>
		<tr><th> QC Type </th><th> Read 1 Status </th><th> Read 2 Status </th></tr>
		{% with summary|keyval:sample as qctype2read2status %}
		{% for qc_type,read2status in qctype2read2status.items %}
		<tr><td> {{ qc_type }}        </td>
		    <td> {{ read2status.R1 }} </td>
     		    <td> {{ read2status.R2 }} </td></tr>
		{% endfor %}
		{% endwith %}
	</table>
	{% endfor %}

	<!-- [ Sample R1 and R2 quality plots ] -->
	<pdf:nextpage>

	<h1> Sample Quality Plots </h1>
	{% for sample in samples %}
	<h2> Sample: {{ sample }} </h2>
	
	{% with images|keyval:sample as qctype2read2imfile %}
	{% for qc_type,read2imagefile in qctype2read2imfile.items %}
	<h3 class='image-title'> {{ qc_type }} </h3>
	<table>
		<tr><th> Read 1 </th>
		    <th> Read 2 </th></tr>
		<tr><td> <img src='{{ read2imagefile.R1 }}' /> </td>
		    <td> <img src='{{ read2imagefile.R2 }}' /> </td></tr>
	</table>
	<br />
	{% if forloop.counter|divisibleby:2 and forloop.counter > 0 %}
		<pdf:nextpage>
	{% endif %}
	{% endfor %}
        {% endwith %}

	{% endfor %}
	<!-- [ Finished looping over samples ]-->

    </body>
</html>