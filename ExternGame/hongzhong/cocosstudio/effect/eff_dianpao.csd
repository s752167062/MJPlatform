<GameFile>
  <PropertyGroup Name="eff_dianpao" Type="Node" ID="6cb399ad-f3a3-4a10-9ec3-d738d8b836e5" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="60" Speed="1.0000" ActivedAnimationName="a0">
        <Timeline ActionTag="-203434393" Property="FileData">
          <TextureFrame FrameIndex="0" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/dianpao/dianpao1.png" Plist="image2/effect/dianpao/Plist.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="5" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/dianpao/dianpao2.png" Plist="image2/effect/dianpao/Plist.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="10" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/dianpao/dianpao3.png" Plist="image2/effect/dianpao/Plist.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="15" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/dianpao/dianpao4.png" Plist="image2/effect/dianpao/Plist.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="60" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="image2/effect/dianpao/dianpao4.png" Plist="image2/effect/dianpao/Plist.plist" />
          </TextureFrame>
        </Timeline>
        <Timeline ActionTag="-203434393" Property="VisibleForFrame">
          <BoolFrame FrameIndex="0" Tween="False" Value="True" />
          <BoolFrame FrameIndex="60" Tween="False" Value="False" />
        </Timeline>
      </Animation>
      <AnimationList>
        <AnimationInfo Name="a0" StartIndex="0" EndIndex="60">
          <RenderColor A="150" R="255" G="215" B="0" />
        </AnimationInfo>
      </AnimationList>
      <ObjectData Name="Node" Tag="73" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="Sprite_9" ActionTag="-203434393" Tag="82" IconVisible="False" LeftMargin="-141.0000" RightMargin="-141.0000" TopMargin="-127.0000" BottomMargin="-127.0000" ctype="SpriteObjectData">
            <Size X="282.0000" Y="254.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
            <FileData Type="MarkedSubImage" Path="image2/effect/dianpao/dianpao1.png" Plist="image2/effect/dianpao/Plist.plist" />
            <BlendFunc Src="1" Dst="771" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>