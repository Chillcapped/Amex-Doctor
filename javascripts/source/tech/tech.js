
function search(){
	console.log('Searching');
	$('#searchForm').submit();
}


//changeTab
//Changes a tab content
function changeTab(type, tabName){

	console.log('Changing Tech Tab');
	var url = '/tech/tabs/'+type+'/'+tabName;
	formData = {
			medCategory: $('#medCategoryFilter').val(),
			containsFormula: $('#formulaFilter').val(),
			insurance: $('#insuranceFilter').val(),
			ipp: $('#filterIPP').val(),
			tab: 'all',
			q: $('#q').val()
	}
	$.post(url, formData, function(data){
		$('#content').html(data);
		$('#contentContainer ul li.blueBtn').removeClass("blueBtn");
		$('#'+tabName+'Tab').addClass("blueBtn");
// alert(tabName);

	});

}

// close dialog box when clicking the darkened outside
$('body').on('click','.ui-widget-overlay',function(){ $('#dialog').dialog('close'); });
