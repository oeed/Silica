<ApplicationContainer theme=red>

	<Button identifier=okayButton x=10 y=10 text=Okay />

	<MenuButton x=60 y=10 text="erm" />

	<SegmentContainer x=120 y=10>
		<SegmentButton text=One isChecked=true />
		<SegmentButton text=Two isChecked=true />
		<SegmentButton text=Three isChecked=true />
	</SegmentContainer>

	

	<ScrollView x=200 y=35 width=100 height=100 >
		<ScrollContainer width=90 height=600 >
			<PathView x=10 width=80 y=35 />
		</ScrollContainer>
	</ScrollView>


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

	<Window x=10 y=10 width=100 height=60 >
		<FontWindowContainer>
		</FontWindowContainer>
	</Window>

	<Window x=50 y=100 width=100 height=60 >
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
	</Window> -->

</ApplicationContainer>