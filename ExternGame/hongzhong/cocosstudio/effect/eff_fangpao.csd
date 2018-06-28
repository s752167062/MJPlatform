<GameFile>
  <PropertyGroup Name="eff_fangpao" Type="Node" ID="2250a92e-ce85-4a9a-a301-6f859530d376" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="60" Speed="1.0000" ActivedAnimationName="a0">
        <Timeline ActionTag="-2040013066" Property="Position">
          <PointFrame FrameIndex="58" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="-2040013066" Property="FileData">
          <TextureFrame FrameIndex="0" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/fangpao/fangpao1.png" Plist="image2/effect/fangpao/Plist.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="5" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/fangpao/fangpao2.png" Plist="image2/effect/fangpao/Plist.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="10" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/fangpao/fangpao3.png" Plist="image2/effect/fangpao/Plist.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="15" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/fangpao/fangpao4.png" Plist="image2/effect/fangpao/Plist.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="60" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/fangpao/fangpao4.png" Plist="image2/effect/fangpao/Plist.plist" />
          </TextureFrame>
        </Timeline>
        <Timeline ActionTag="-2040013066" Property="VisibleForFrame">
          <BoolFrame FrameIndex="0" Tween="False" Value="True" />
          <BoolFrame FrameIndex="60" Tween="False" Value="False" />
        </Timeline>
      </Animation>
      <AnimationList>
        <AnimationInfo Name="a0" StartIndex="0" EndIndex="60">
          <RenderColor A="150" R="233" G="150" B="122" />
        </AnimationInfo>
      </AnimationList>
      <ObjectData Name="Node" Tag="83" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="Sprite_1" ActionTag="-2040013066" Tag="84" IconVisible="False" LeftMargin="-141.0000" RightMargin="-141.0000" TopMargin="-127.0000" BottomMargin="-127.0000" ctype="SpriteObjectData">
            <Size X="282.0000" Y="254.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="MarkedSubImage" Path="image2/effect/fangpao/fangpao1.png" Plist="image2/effect/fangpao/Plist.plist" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>