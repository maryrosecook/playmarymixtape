// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function validateSearch()
{		
	validSearchFilter = /•/i
	var search = document.getElementById("search_text").value;
	if(validSearchFilter.test(search))
	{
		return true;
	}
	else
	{
		return false;
	}
}

function showRestOfForm(field)
{
	Element.show('rest_of_form_find');
}

function checkMP3AndContinue(field)
{
	mp3Filter = /\.mp3$/i
	if(mp3Filter.test(field.value))
	{
		Element.hide('mp3_extension_error');
		//Element.hide('find_form');
		//Element.hide('central_or');
		Element.show('upload_rest_of_form');
	}
	else
	{
		Element.hide('upload_rest_of_form');
		Element.show('mp3_extension_error');
	}
}

// handles fields w/ specific preloaded text that must be greyed out
function processPreloadedText(field, event, defaultText)
{
	if(event == 'onfocus')
	{
		if(field.value == defaultText)
		{
			field.value = '';
			field.removeClassName('inactive_preloaded_field');
			field.addClassName('active_preloaded_field');
		}
	}
	else if(event == 'onblur')
	{
		if(field.value == '')
		{
			field.value = defaultText;
			field.addClassName('inactive_preloaded_field');
			field.removeClassName('active_preloaded_field');
		}
	}
}

function disableWith(button, newLabel)
{
	button.setAttribute('originalValue', button.value);
	button.disabled = true;
	button.value = newLabel;
	
	result = (button.form.onsubmit ? (button.form.onsubmit() ? button.form.submit() : false) : button.form.submit());
	if (result == false)
	{ 
		button.value = button.getAttribute('originalValue');
		button.disabled = false 
	}
	
	return result;
}