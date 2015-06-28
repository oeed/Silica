<ApplicationContainer>

	<Button identifier=okayButton x=10 y=10 text=Okay />

	<MenuButton x=60 y=10 text=Okay />

	<Checkbox identifier=agreeCheckbox x=10 y=40 isChecked=true />


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

	
	<!-- <PathView x=70 y=35 /> -->

	<!-- <ProgressBar  x=70 y=150 /> -->
	<!-- <ProgressBar  x=70 y=130 />
	<ProgressBar  x=70 y=110 />
	<ProgressBar  x=70 y=90 />
	<ProgressBar  x=70 y=70 />
	<ProgressBar  x=70 y=140 />
	<ProgressBar  x=70 y=120 />
	<ProgressBar  x=70 y=100 />
	<ProgressBar  x=70 y=80 />
	<ProgressBar  x=70 y=60 /> -->

	<Window x=50 y=10 width=80 height=60 >
		<FontWindowContainer>
			<!-- <ProgressBar x=6 y=35 />
			<MenuButton x=5 y=5 text=Okay />
			<Checkbox identifier=agreeCheckbox x=5 y=25 isChecked=true />
			<Container x=60 y=5 width=20 height=40>
				<Radio y=1 isChecked=true />
				<Radio y=11/>
				<Radio y=21/>
			</Container> -->
		</FontWindowContainer>
	</Window>

	<Window x=150 y=40 width=80 height=60 >
		<WindowContainer>
			<ProgressBar x=6 y=35 />
			<Button x=5 y=5 text=Okay />
			<Checkbox identifier=agreeCheckbox x=5 y=25 isChecked=true />
			<Container x=50 y=5 width=20 height=40>
				<Radio y=1 isChecked=true />
				<Radio y=11/>
				<Radio y=21/>
			</Container>
		</WindowContainer>
	</Window>

</ApplicationContainer>