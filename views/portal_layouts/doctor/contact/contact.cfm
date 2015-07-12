
<div id="topContactContainer">

	<h2>Contact</h2>

	<div class="contactLeft">Question</div>
	<div class="contactRight">
	<ul class="contactInfoBlock">
		<li>Pharmacy: 555-555-5555</li>
		<li>General: 555-555-5555</li>
		<li>Administration: 555-555-5555</li>
		<li>Fax: 555-555-5555</li>
	</ul>
	<ul  class="contactInfoBlock">
		<li>1515 Elizabet Street, Suite J.</li>
		<li>Melbourne, FL 32901</li>
		<li><br /></li>
		<li>Email: support@rxportal.io</li>
	</ul>
	<div id="topCustomCompFormContainer" class="clear">
		<form action="/doctor/contact" id="#contactForm">

			<textarea name="question" id="customCompQuestion"></textarea>
			<input type="hidden" name="doctor">
			<ul class="contactBtns clear">
				<a href="javascript:submitQuestion();"><div class="clear contBtnDiv blueCont contBtnAdd submitterReplace contactFormBtn">Ask Question<input type="submit" value="Ask Question" style="display:none"></div></a>
				<a href="javascript:closeDialog();"><div class="contBtnDiv redCont contBtnX">Cancel</div></a>
			</ul>
		</form>
	</div>
</div>
</div>

<!--- Include Custom Compound inquiry
<cfinclude template="compoundInquiry.cfm" /> --->
