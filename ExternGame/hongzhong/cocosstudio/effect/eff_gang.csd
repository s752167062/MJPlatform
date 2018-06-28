<GameFile>
  <PropertyGroup Name="eff_gang" Type="Node" ID="2c13ea06-a8ed-4579-8ff8-4b4b02508f86" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="25" Speed="1.0000" ActivedAnimationName="a1">
        <Timeline ActionTag="-583389927" Property="FileData">
          <TextureFrame FrameIndex="0" Tween="False">
            <TextureFile Type="PlistSubImage" Path="gang/gang1.png" Plist="image/effect1.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="5" Tween="False">
            <TextureFile Type="PlistSubImage" Path="gang/gang2.png" Plist="image/effect1.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="10" Tween="False">
            <TextureFile Type="PlistSubImage" Path="gang/gang3.png" Plist="image/effect1.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="15" Tween="False">
            <TextureFile Type="PlistSubImage" Path="gang/gang4.png" Plist="image/effect1.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="20" Tween="False">
            <TextureFile Type="PlistSubImage" Path="gang/gang5.png" Plist="image/effect1.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="25" Tween="False">
            <TextureFile Type="PlistSubImage" Path="gang/gang6.png" Plist="image/effect1.plist" />
          </TextureFrame>
        </Timeline>
      </Animation>
      <AnimationList>
        <AnimationInfo Name="a1" StartIndex="0" EndIndex="25">
          <RenderColor A="255" R="255" G="255" B="0" />
        </AnimationInfo>
      </AnimationList>
      <ObjectData Name="Node" Tag="48" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="gang" ActionTag="-583389927" Tag="49" IconVisible="False" LeftMargin="-95.0000" RightMargin="-95.0000" TopMargin="-149.0000" BottomMargin="-149.0000" ctype="SpriteObjectData">
            <Size X="190.0000" Y="298.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="PlistSubImage" Path="gang/gang1.png" Plist="image/effect1.plist" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>