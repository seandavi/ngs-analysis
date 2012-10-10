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
				margin-bottom: .5cm; 
				height: 10cm; 
                	}
			@frame footer {
				-pdf-frame-content: footerContent;
				bottom: .3cm;
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
				margin-bottom: .5cm; 
				height: 10cm; 
                	}
			@frame footer {
				-pdf-frame-content: footerContent;
				bottom: .3cm;
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
		<p>{{ title }} NGS Services</p>
	</div>
        <div id="footerContent">
		<pdf:pagenumber>
        </div>


	<!-- [ Title page ] -->
	<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
	<p class='report-title'> {{ title }} </p>
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
		<tr><th> Filename </th><th> File size </th></tr>
		{% for sample in samples %}
		<tr><td> {{ data|keyval:sample|keyval:"FastqFilename"|keyval:"R1" }} </td>
		    <td> {{ data|keyval:sample|keyval:"FastqFilesize"|keyval:"R1" }} </td></tr>
			{% if data|keyval:sample|keyval:"MD5Filesize" != "" %}
			<tr><td> {{ data|keyval:sample|keyval:"MD5Filename"|keyval:"R1" }} </td>
			    <td> {{ data|keyval:sample|keyval:"MD5Filesize"|keyval:"R1" }} </td></tr>
			{% endif %}
		<tr><td> {{ data|keyval:sample|keyval:"FastqFilename"|keyval:"R2" }} </td>
		    <td> {{ data|keyval:sample|keyval:"FastqFilesize"|keyval:"R2" }} </td></tr>
			{% if data|keyval:sample|keyval:"MD5Filesize" != "" %}
			<tr><td> {{ data|keyval:sample|keyval:"MD5Filename"|keyval:"R2" }} </td>
			    <td> {{ data|keyval:sample|keyval:"MD5Filesize"|keyval:"R2" }} </td></tr>
			{% endif %}
		{% endfor %}
	</table>


	<br /><br />
	<h2> Sequence Summary </h2>
	<table>
		<tr><th> Sample         </th>
		    <th> Barcode        </th>
		    <th> Read Length    </th>
		    <th> Read Count     </th>
		    <th> Base Count     </th>
		    <th> % Bases >= Q30 </th>
		    <th> Mean QScore    </th>
		    <th> %GC            </th></tr>
		{% for sample in samples %}
		<tr><td> {{ sample }}   </td>
		    <td> {{ seqsum|keyval:sample|keyval:"barcode" }}
		         ({{ seqsum|keyval:sample|keyval:"barcode_index" }})                        </td>
		    <td> {{ data|keyval:sample|keyval:"Sequence length"|keyval:"R1" }}              </td>
		    <td> 2 x {{ data|keyval:sample|keyval:"Total Sequences"|keyval:"R1"|intcomma }} </td>
		    <td> 2 x {{ seqsum|keyval:sample|keyval:"reads"|intcomma }}                     </td>
		    <td> {{ seqsum|keyval:sample|keyval:"gt_Q30" }}%                                </td>
		    <td> {{ seqsum|keyval:sample|keyval:"mean_Q" }}                                 </td>
		    <td> R1: {{ data|keyval:sample|keyval:"%GC"|keyval:"R1" }}%, 
		         R2: {{ data|keyval:sample|keyval:"%GC"|keyval:"R2" }}%                     </td></tr>
		{% endfor %}
	</table>
	

	
	<pdf:nextpage>
	<h2> Quality Summary </h2>
	{% for sample in samples %}
	{% if forloop.counter0 > 0 %}<br />{% endif %}
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
	{% if forloop.counter0 > 0 %}<pdf:nextpage>{% endif %}
	<h2> Sample: {{ sample }} </h2>
	
	{% with images|keyval:sample as qctype2read2imfile %}
	{% for qc_type,read2imagefile in qctype2read2imfile.items %}
	{% with qc_type|fastqc_context2summary_text as summary_title %}
	{% with summary|keyval:sample|keyval:summary_title as read2status %}

	<h3 class='image-title'> {{ qc_type|fastqc_context2title_text }} </h3>
	<table>
		<tr><th> Read 1 {{ read2status.R1 }}</th>
		    <th> Read 2 {{ read2status.R2 }}</th></tr>
		<tr><td> <img src='{{ read2imagefile.R1 }}' /> </td>
		    <td> <img src='{{ read2imagefile.R2 }}' /> </td></tr>
	</table>
	<br />
	{% if forloop.counter|divisibleby:2 and forloop.counter > 0 %}
		<pdf:nextpage>
	{% endif %}

	{% endwith %}
	{% endwith %}
	{% endfor %}
        {% endwith %}

	{% endfor %}
	<!-- [ Finished looping over samples ]-->



	<!-- [ Appendix ] -->
	<pdf:nextpage>
	<h1> Appendix </h1>
	
	<h2> Adapter Sequences </h2>
	{% with appendix|keyval:"adapter" as data_appendix_adapter %}
	<p>
	{% for description_line in data_appendix_adapter|keyval:"descriptions" %}
	{{ description_line }} <br />
	{% endfor %}
	</p>

	<table>
	{% with data_appendix_adapter|keyval:"colheaders" as colheaders %}
	<tr> <th width=6%>  {{ colheaders.0 }} </th>
             <th width=10%> {{ colheaders.1 }} </th>
             <th width=84%> {{ colheaders.2 }} </th></tr>
	{% endwith %}
	{% for adapter_row in data_appendix_adapter|keyval:"adapters" %}
	<tr>
	  {% for col in adapter_row %}
	    <td> {{ col }} </td>
	  {% endfor %}
	</tr>
	{% endfor %}
	</table>

	{% endwith %}



	<pdf:nextpage>
	<h2> Example Quality Plots </h2>
	{% with appendix|keyval:"example_fastqc" as qctype2type2imfile %}
	{% with appendix|keyval:"qc_standards" as qctype2warnfail2text %}
	{% for qc_type,type2imagefile in qctype2type2imfile.items %}
	{% if forloop.counter0 > 0 %}<br />{% endif %}
        <h3 class='image-title'> {{ qc_type|fastqc_context2title_text }} </h3>
        <table>
                <tr><th> Good 									  </th>
	            <th> Bad  									  </th></tr>
                <tr><td> <img src='{{ type2imagefile.good }}' />                                  </td>
                    <td> <img src='{{ type2imagefile.bad }}' />                                   </td></tr>
		<tr><td colspan=2> {{ qctype2warnfail2text|keyval:qc_type|keyval:"warn" }} <br /> 
				   {{ qctype2warnfail2text|keyval:qc_type|keyval:"fail" }}        </td></tr>
        </table>
        <br />
	{% if forloop.counter|divisibleby:2 and forloop.counter > 0 %}
                <pdf:nextpage>
        {% endif %}	
        {% endfor %}
        {% endwith %}
	{% endwith %}

    </body>
</html>