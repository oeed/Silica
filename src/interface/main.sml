<ApplicationContainer>

	<Button identifier=okayButton x=10 y=10 text=Okay />

	<MenuButton x=60 y=10 text=Okay />

	<Checkbox identifier=agreeCheckbox x=10 y=40 isChecked=true />

	<Container x=10 y=60 width=20 height=40>
		<Radio y=1 isChecked=true />
		<Radio y=11/>
		<Radio y=21/>
	</Container>

	<Container x=50 y=60 width=20 height=40>
		<Radio y=1 isChecked=true />
		<Radio y=11/>
		<Radio y=21/>
	</Container>

	<SegmentContainer x=120 y=10>
		<SegmentButton text=One isChecked=true />
		<SegmentButton text=Two isChecked=true />
		<SegmentButton text=Three isChecked=true />
	</SegmentContainer>

	
	<PathView x=70 y=35 />

	<ProgressBar  x=70 y=150 />

	<Window x=150 y=40 width=130 height=90 >
		<WindowContainer>
	<Button identifier=okayButton x=10 y=10 text=Okay />
		</WindowContainer>
	</Window>

</ApplicationContainer>