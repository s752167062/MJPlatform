<GameFile>
  <PropertyGroup Name="LobbyScene" Type="Scene" ID="3174cc00-7e30-4f86-a1ab-2211fd5bf9e7" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="60" Speed="1.0000" ActivedAnimationName="a0">
        <Timeline ActionTag="1529199808" Property="FileData">
          <TextureFrame FrameIndex="0" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="ui_activity/activity_eff1.png" Plist="ui_activity/activity_eff.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="12" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="ui_activity/activity_eff2.png" Plist="ui_activity/activity_eff.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="24" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="ui_activity/activity_eff3.png" Plist="ui_activity/activity_eff.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="36" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="ui_activity/activity_eff4.png" Plist="ui_activity/activity_eff.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="48" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="ui_activity/activity_eff5.png" Plist="ui_activity/activity_eff.plist" />
          </TextureFrame>
          <TextureFrame FrameIndex="60" Tween="False">
            <TextureFile Type="MarkedSubImage" Path="ui_activity/activity_eff1.png" Plist="ui_activity/activity_eff.plist" />
          </TextureFrame>
        </Timeline>
      </Animation>
      <AnimationList>
        <AnimationInfo Name="a0" StartIndex="0" EndIndex="60">
          <RenderColor A="255" R="238" G="130" B="238" />
        </AnimationInfo>
      </AnimationList>
      <ObjectData Name="Scene" Tag="13" ctype="GameNodeObjectData">
        <Size X="1136.0000" Y="640.0000" />
        <Children>
          <AbstractNodeData Name="bg" ActionTag="890868556" Tag="48" IconVisible="False" HorizontalEdge="BothEdge" VerticalEdge="BothEdge" StretchWidthEnable="True" StretchHeightEnable="True" LeftEage="316" RightEage="316" TopEage="178" BottomEage="178" Scale9OriginX="316" Scale9OriginY="178" Scale9Width="504" Scale9Height="284" ctype="ImageViewObjectData">
            <Size X="1136.0000" Y="640.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="568.0000" Y="320.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <FileData Type="Normal" Path="image2/hall/bg.jpg" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="Image_7" ActionTag="572387159" Tag="341" IconVisible="False" PositionPercentXEnabled="True" RightMargin="859.0000" BottomMargin="517.0000" LeftEage="84" RightEage="84" TopEage="31" BottomEage="31" Scale9OriginX="84" Scale9OriginY="31" Scale9Width="109" Scale9Height="61" ctype="ImageViewObjectData">
            <Size X="277.0000" Y="123.0000" />
            <AnchorPoint ScaleY="1.0000" />
            <Position Y="640.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition Y="1.0000" />
            <PreSize X="0.2438" Y="0.1922" />
            <FileData Type="MarkedSubImage" Path="image2/hall/logo.png" Plist="image2/hall/hall_2.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="phoneInfo" ActionTag="-1588743943" Tag="66" IconVisible="False" LeftMargin="1026.1509" RightMargin="9.8491" TopMargin="6.2186" BottomMargin="583.7814" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="100.0000" Y="50.0000" />
            <Children>
              <AbstractNodeData Name="pNetSignal" ActionTag="645925201" Tag="67" IconVisible="False" LeftMargin="5.0000" RightMargin="55.0000" TopMargin="5.0000" BottomMargin="5.0000" LeftEage="13" RightEage="13" TopEage="13" BottomEage="13" Scale9OriginX="13" Scale9OriginY="13" Scale9Width="14" Scale9Height="14" ctype="ImageViewObjectData">
                <Size X="40.0000" Y="40.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="25.0000" Y="25.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2500" Y="0.5000" />
                <PreSize X="0.4000" Y="0.8000" />
                <FileData Type="Normal" Path="image2/hall/net_3.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="pBattery_bg" ActionTag="-1983614825" Tag="68" IconVisible="False" LeftMargin="48.3329" RightMargin="3.6671" TopMargin="13.5000" BottomMargin="13.5000" LeftEage="15" RightEage="15" TopEage="7" BottomEage="7" Scale9OriginX="15" Scale9OriginY="7" Scale9Width="18" Scale9Height="9" ctype="ImageViewObjectData">
                <Size X="48.0000" Y="23.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="72.3329" Y="25.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.7233" Y="0.5000" />
                <PreSize X="0.4800" Y="0.4600" />
                <FileData Type="Normal" Path="image2/hall/power_bg.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="pBattery" ActionTag="-2023819276" Tag="69" IconVisible="False" LeftMargin="48.0000" RightMargin="4.0000" TopMargin="13.5000" BottomMargin="13.5000" ProgressInfo="56" ctype="LoadingBarObjectData">
                <Size X="48.0000" Y="23.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="72.0000" Y="25.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.7200" Y="0.5000" />
                <PreSize X="0.4800" Y="0.4600" />
                <ImageFileData Type="Normal" Path="image2/hall/power.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position X="1026.1509" Y="583.7814" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.9033" Y="0.9122" />
            <PreSize X="0.0880" Y="0.0781" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_awards" ActionTag="-1425197006" VisibleForFrame="False" Tag="58" IconVisible="False" HorizontalEdge="RightEdge" VerticalEdge="TopEdge" LeftMargin="791.5329" RightMargin="276.4671" TopMargin="97.5624" BottomMargin="474.4376" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="38" Scale9Height="46" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="68.0000" Y="68.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="825.5329" Y="508.4376" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.7267" Y="0.7944" />
            <PreSize X="0.0599" Y="0.1063" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="PlistSubImage" Path="lobbyUI_adwardBtn.png" Plist="image/ui_lobby.plist" />
            <PressedFileData Type="PlistSubImage" Path="lobbyUI_adwardBtn.png" Plist="image/ui_lobby.plist" />
            <NormalFileData Type="PlistSubImage" Path="lobbyUI_adwardBtn.png" Plist="image/ui_lobby.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_pingJiangFan" ActionTag="179345813" VisibleForFrame="False" Tag="63" IconVisible="False" HorizontalEdge="RightEdge" VerticalEdge="BottomEdge" LeftMargin="583.9976" RightMargin="40.0024" TopMargin="166.0080" BottomMargin="79.9920" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="482" Scale9Height="372" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="512.0000" Y="394.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="839.9976" Y="276.9920" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.7394" Y="0.4328" />
            <PreSize X="0.4507" Y="0.6156" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="PlistSubImage" Path="lobbyUI_pingJiangFanBtn.png" Plist="image/ui_lobby.plist" />
            <PressedFileData Type="PlistSubImage" Path="lobbyUI_pingJiangFanBtn.png" Plist="image/ui_lobby.plist" />
            <NormalFileData Type="PlistSubImage" Path="lobbyUI_pingJiangFanBtn.png" Plist="image/ui_lobby.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_hongZhongMaJiang" ActionTag="1724569959" Tag="62" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="BottomEdge" LeftMargin="377.5000" RightMargin="423.5000" TopMargin="72.5000" BottomMargin="86.5000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="305" Scale9Height="459" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="335.0000" Y="481.0000" />
            <Children>
              <AbstractNodeData Name="Image_1" ActionTag="-1176976262" Tag="59" IconVisible="False" LeftMargin="-3.4339" RightMargin="10.4339" TopMargin="3.9771" BottomMargin="44.0229" LeftEage="108" RightEage="108" TopEage="142" BottomEage="142" Scale9OriginX="108" Scale9OriginY="142" Scale9Width="112" Scale9Height="149" ctype="ImageViewObjectData">
                <Size X="328.0000" Y="433.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="160.5661" Y="260.5229" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4793" Y="0.5416" />
                <PreSize X="0.9791" Y="0.9002" />
                <FileData Type="Normal" Path="image2/hall/pic_hongzhong.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_2" ActionTag="637784612" Tag="58" IconVisible="False" LeftMargin="11.0732" RightMargin="7.9268" TopMargin="381.1350" BottomMargin="29.8650" LeftEage="104" RightEage="104" TopEage="23" BottomEage="23" Scale9OriginX="104" Scale9OriginY="23" Scale9Width="108" Scale9Height="24" ctype="ImageViewObjectData">
                <Size X="316.0000" Y="70.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="169.0732" Y="64.8650" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5047" Y="0.1349" />
                <PreSize X="0.9433" Y="0.1455" />
                <FileData Type="Normal" Path="image2/hall/pic_hongzhong_2.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="545.0000" Y="327.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.4798" Y="0.5109" />
            <PreSize X="0.2949" Y="0.7516" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="image2/hall/btn_hongzhong.png" Plist="image2/hall/hall_2.plist" />
            <PressedFileData Type="MarkedSubImage" Path="image2/hall/btn_hongzhong.png" Plist="image2/hall/hall_2.plist" />
            <NormalFileData Type="MarkedSubImage" Path="image2/hall/btn_hongzhong.png" Plist="image2/hall/hall_2.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_match" ActionTag="-1500641817" Tag="127" IconVisible="False" HorizontalEdge="RightEdge" VerticalEdge="BottomEdge" LeftMargin="710.0000" RightMargin="106.0000" TopMargin="98.0000" BottomMargin="326.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="290" Scale9Height="194" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="320.0000" Y="216.0000" />
            <Children>
              <AbstractNodeData Name="Image_1" ActionTag="-1579113685" Tag="53" IconVisible="False" LeftMargin="7.3603" RightMargin="6.6397" TopMargin="-19.0000" BottomMargin="51.0000" LeftEage="100" RightEage="100" TopEage="60" BottomEage="60" Scale9OriginX="100" Scale9OriginY="60" Scale9Width="106" Scale9Height="64" ctype="ImageViewObjectData">
                <Size X="306.0000" Y="184.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="160.3603" Y="143.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5011" Y="0.6620" />
                <PreSize X="0.9563" Y="0.8519" />
                <FileData Type="Normal" Path="image2/hall/pic_majiangdasai.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_2" ActionTag="625761848" Tag="54" IconVisible="False" LeftMargin="3.1627" RightMargin="2.8373" TopMargin="126.9464" BottomMargin="23.0536" LeftEage="103" RightEage="103" TopEage="21" BottomEage="21" Scale9OriginX="103" Scale9OriginY="21" Scale9Width="108" Scale9Height="24" ctype="ImageViewObjectData">
                <Size X="314.0000" Y="66.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="160.1627" Y="56.0536" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5005" Y="0.2595" />
                <PreSize X="0.9812" Y="0.3056" />
                <FileData Type="Normal" Path="image2/hall/pic_majiangdasai_2.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="870.0000" Y="434.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.7658" Y="0.6781" />
            <PreSize X="0.2817" Y="0.3375" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="image2/hall/btn_majiangdasai.png" Plist="image2/hall/hall_2.plist" />
            <PressedFileData Type="MarkedSubImage" Path="image2/hall/btn_majiangdasai.png" Plist="image2/hall/hall_2.plist" />
            <NormalFileData Type="MarkedSubImage" Path="image2/hall/btn_majiangdasai.png" Plist="image2/hall/hall_2.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_joinRoom" ActionTag="1680762614" Tag="55" IconVisible="False" HorizontalEdge="RightEdge" VerticalEdge="BottomEdge" LeftMargin="710.0000" RightMargin="106.0000" TopMargin="298.0000" BottomMargin="86.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="290" Scale9Height="234" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="320.0000" Y="256.0000" />
            <Children>
              <AbstractNodeData Name="Image_1" ActionTag="2115386857" Tag="56" IconVisible="False" LeftMargin="-3.6397" RightMargin="-4.3603" BottomMargin="30.0000" LeftEage="100" RightEage="100" TopEage="60" BottomEage="60" Scale9OriginX="100" Scale9OriginY="60" Scale9Width="128" Scale9Height="106" ctype="ImageViewObjectData">
                <Size X="328.0000" Y="226.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="160.3603" Y="143.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5011" Y="0.5586" />
                <PreSize X="1.0250" Y="0.8828" />
                <FileData Type="Normal" Path="image2/hall/pic_jiarufangjian.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_2" ActionTag="1402702324" Tag="57" IconVisible="False" LeftMargin="2.1627" RightMargin="1.8373" TopMargin="140.0000" BottomMargin="30.0000" LeftEage="103" RightEage="103" TopEage="21" BottomEage="21" Scale9OriginX="103" Scale9OriginY="21" Scale9Width="110" Scale9Height="44" ctype="ImageViewObjectData">
                <Size X="316.0000" Y="86.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="160.1627" Y="73.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5005" Y="0.2852" />
                <PreSize X="0.9875" Y="0.3359" />
                <FileData Type="Normal" Path="image2/hall/pic_jiarufangjian_2.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="870.0000" Y="214.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.7658" Y="0.3344" />
            <PreSize X="0.2817" Y="0.4000" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="Normal" Path="image2/hall/btn_jiarufangjian.png" Plist="" />
            <PressedFileData Type="Normal" Path="image2/hall/btn_jiarufangjian.png" Plist="" />
            <NormalFileData Type="Normal" Path="image2/hall/btn_jiarufangjian.png" Plist="" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="txt_version" ActionTag="-482633239" Tag="19" IconVisible="False" LeftMargin="1054.6802" RightMargin="10.3198" TopMargin="527.2857" BottomMargin="81.7143" FontSize="26" LabelText="v1.0.1" HorizontalAlignmentType="HT_Right" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="71.0000" Y="31.0000" />
            <AnchorPoint ScaleX="1.0000" ScaleY="0.5000" />
            <Position X="1125.6802" Y="97.2143" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="205" G="179" B="12" />
            <PrePosition X="0.9909" Y="0.1519" />
            <PreSize X="0.0625" Y="0.0484" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="ctn_activity" Visible="False" ActionTag="-1229507734" VisibleForFrame="False" Tag="97" IconVisible="True" HorizontalEdge="RightEdge" VerticalEdge="TopEdge" LeftMargin="849.0000" RightMargin="287.0000" TopMargin="52.0000" BottomMargin="588.0000" ctype="SingleNodeObjectData">
            <Size X="0.0000" Y="0.0000" />
            <Children>
              <AbstractNodeData Name="eff_active" ActionTag="1529199808" VisibleForFrame="False" Tag="45" IconVisible="False" LeftMargin="-50.5000" RightMargin="-50.5000" TopMargin="-53.0000" BottomMargin="-53.0000" ctype="SpriteObjectData">
                <Size X="101.0000" Y="106.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="MarkedSubImage" Path="ui_activity/activity_eff1.png" Plist="ui_activity/activity_eff.plist" />
                <BlendFunc Src="1" Dst="771" />
              </AbstractNodeData>
              <AbstractNodeData Name="btn_activity" ActionTag="1862454192" Tag="22" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="-33.0000" RightMargin="-33.0000" TopMargin="-33.0000" BottomMargin="-33.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="44" Scale9Height="55" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="66.0000" Y="66.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Normal" Path="image/btn_activity.png" Plist="" />
                <PressedFileData Type="Normal" Path="image/btn_activity.png" Plist="" />
                <NormalFileData Type="Normal" Path="image/btn_activity.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position X="849.0000" Y="588.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.7474" Y="0.9187" />
            <PreSize X="0.0000" Y="0.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="right" ActionTag="-1867287729" Tag="65" IconVisible="False" LeftMargin="1032.0000" TopMargin="78.0000" BottomMargin="85.0000" LeftEage="34" RightEage="34" TopEage="157" BottomEage="157" Scale9OriginX="34" Scale9OriginY="157" Scale9Width="36" Scale9Height="163" ctype="ImageViewObjectData">
            <Size X="104.0000" Y="477.0000" />
            <AnchorPoint ScaleX="1.0000" />
            <Position X="1136.0000" Y="85.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="1.0000" Y="0.1328" />
            <PreSize X="0.0915" Y="0.7453" />
            <FileData Type="Normal" Path="image2/hall/pic_menu_right.png" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_feedback" ActionTag="1956055509" Tag="60" IconVisible="False" HorizontalEdge="RightEdge" VerticalEdge="TopEdge" LeftMargin="1070.0000" RightMargin="14.0000" TopMargin="102.5000" BottomMargin="462.5000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="22" Scale9Height="53" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="52.0000" Y="75.0000" />
            <AnchorPoint ScaleX="1.0000" ScaleY="0.5000" />
            <Position X="1122.0000" Y="500.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.9877" Y="0.7813" />
            <PreSize X="0.0458" Y="0.1172" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="image2/hall/btn_fankui.png" Plist="image2/hall/hall_2.plist" />
            <PressedFileData Type="MarkedSubImage" Path="image2/hall/btn_fankui.png" Plist="image2/hall/hall_2.plist" />
            <NormalFileData Type="MarkedSubImage" Path="image2/hall/btn_fankui.png" Plist="image2/hall/hall_2.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_msg" ActionTag="-1661663549" Tag="45" IconVisible="False" HorizontalEdge="RightEdge" VerticalEdge="TopEdge" LeftMargin="1070.0000" RightMargin="14.0000" TopMargin="181.0000" BottomMargin="381.0000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="22" Scale9Height="56" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="52.0000" Y="78.0000" />
            <Children>
              <AbstractNodeData Name="ctn_tips" ActionTag="-306388209" VisibleForFrame="False" Tag="48" IconVisible="True" LeftMargin="-29.0000" RightMargin="81.0000" TopMargin="81.0000" BottomMargin="-3.0000" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <Children>
                  <AbstractNodeData Name="img_tips" ActionTag="-809700477" Tag="46" IconVisible="False" LeftMargin="41.6000" RightMargin="-61.6000" TopMargin="-64.1177" BottomMargin="44.1177" ctype="SpriteObjectData">
                    <Size X="20.0000" Y="20.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="51.6000" Y="54.1177" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="0" B="0" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="PlistSubImage" Path="SelectSvr_greenPoint.png" Plist="image/ui_common.plist" />
                    <BlendFunc Src="1" Dst="771" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="Text_1" ActionTag="1546612465" Tag="47" IconVisible="False" LeftMargin="48.6001" RightMargin="-54.6001" TopMargin="-65.3003" BottomMargin="42.3003" FontSize="20" LabelText="!" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="6.0000" Y="23.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="51.6001" Y="53.8003" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="-29.0000" Y="-3.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="-0.5577" Y="-0.0385" />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="1.0000" ScaleY="0.5000" />
            <Position X="1122.0000" Y="420.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.9877" Y="0.6563" />
            <PreSize X="0.0458" Y="0.1219" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="image2/hall/btn_xiaoxi.png" Plist="image2/hall/hall_2.plist" />
            <PressedFileData Type="MarkedSubImage" Path="image2/hall/btn_xiaoxi.png" Plist="image2/hall/hall_2.plist" />
            <NormalFileData Type="MarkedSubImage" Path="image2/hall/btn_xiaoxi.png" Plist="image2/hall/hall_2.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_rule" ActionTag="1933894581" Tag="61" IconVisible="False" HorizontalEdge="RightEdge" VerticalEdge="TopEdge" LeftMargin="1070.0000" RightMargin="14.0000" TopMargin="266.0000" BottomMargin="296.0000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="22" Scale9Height="56" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="52.0000" Y="78.0000" />
            <AnchorPoint ScaleX="1.0000" ScaleY="0.5000" />
            <Position X="1122.0000" Y="335.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.9877" Y="0.5234" />
            <PreSize X="0.0458" Y="0.1219" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="image2/hall/btn_wanfa.png" Plist="image2/hall/hall_2.plist" />
            <PressedFileData Type="MarkedSubImage" Path="image2/hall/btn_wanfa.png" Plist="image2/hall/hall_2.plist" />
            <NormalFileData Type="MarkedSubImage" Path="image2/hall/btn_wanfa.png" Plist="image2/hall/hall_2.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_combatGains" ActionTag="-2050118035" Tag="59" IconVisible="False" HorizontalEdge="RightEdge" VerticalEdge="TopEdge" LeftMargin="1070.0000" RightMargin="14.0000" TopMargin="349.0000" BottomMargin="209.0000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="22" Scale9Height="60" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="52.0000" Y="82.0000" />
            <AnchorPoint ScaleX="1.0000" ScaleY="0.5000" />
            <Position X="1122.0000" Y="250.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.9877" Y="0.3906" />
            <PreSize X="0.0458" Y="0.1281" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="image2/hall/btn_zhanji.png" Plist="image2/hall/hall_2.plist" />
            <PressedFileData Type="MarkedSubImage" Path="image2/hall/btn_zhanji.png" Plist="image2/hall/hall_2.plist" />
            <NormalFileData Type="MarkedSubImage" Path="image2/hall/btn_zhanji.png" Plist="image2/hall/hall_2.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_exitgame" ActionTag="1926570112" Tag="56" IconVisible="False" HorizontalEdge="RightEdge" VerticalEdge="TopEdge" LeftMargin="1070.0000" RightMargin="14.0000" TopMargin="434.0000" BottomMargin="124.0000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="22" Scale9Height="60" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="52.0000" Y="82.0000" />
            <AnchorPoint ScaleX="1.0000" ScaleY="0.5000" />
            <Position X="1122.0000" Y="165.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.9877" Y="0.2578" />
            <PreSize X="0.0458" Y="0.1281" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="image2/hall/btn_tuichu.png" Plist="image2/hall/hall_2.plist" />
            <PressedFileData Type="MarkedSubImage" Path="image2/hall/btn_tuichu.png" Plist="image2/hall/hall_2.plist" />
            <NormalFileData Type="MarkedSubImage" Path="image2/hall/btn_tuichu.png" Plist="image2/hall/hall_2.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="bottom" ActionTag="389711261" Tag="60" IconVisible="False" TopMargin="570.0000" LeftEage="374" RightEage="374" TopEage="23" BottomEage="23" Scale9OriginX="374" Scale9OriginY="23" Scale9Width="388" Scale9Height="24" ctype="ImageViewObjectData">
            <Size X="1136.0000" Y="70.0000" />
            <AnchorPoint />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="1.0000" Y="0.1094" />
            <FileData Type="Normal" Path="image2/hall/dibu_bg.png" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="headPanel" ActionTag="576385675" Tag="282" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="10.0000" RightMargin="1053.0000" TopMargin="557.0000" BottomMargin="10.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ComboBoxIndex="1" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="73.0000" Y="73.0000" />
            <Children>
              <AbstractNodeData Name="icon_bg" ActionTag="-1561633671" Tag="52" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" TouchEnable="True" LeftEage="24" RightEage="24" TopEage="24" BottomEage="24" Scale9OriginX="24" Scale9OriginY="24" Scale9Width="117" Scale9Height="118" ctype="ImageViewObjectData">
                <Size X="73.0000" Y="73.0000" />
                <Children>
                  <AbstractNodeData Name="baseicon" ActionTag="325174551" Tag="111" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="4.0000" RightMargin="4.0000" TopMargin="4.0000" BottomMargin="4.0000" LeftEage="20" RightEage="20" TopEage="20" BottomEage="20" Scale9OriginX="20" Scale9OriginY="20" Scale9Width="21" Scale9Height="21" ctype="ImageViewObjectData">
                    <Size X="65.0000" Y="65.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="36.5000" Y="36.5000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.5000" />
                    <PreSize X="0.8904" Y="0.8904" />
                    <FileData Type="Normal" Path="image2/room/head/head2.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="36.5000" Y="36.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="1.0000" Y="1.0000" />
                <FileData Type="Normal" Path="image2/room/head/head_frame2.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position X="10.0000" Y="10.0000" />
            <Scale ScaleX="1.1100" ScaleY="1.1100" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.0088" Y="0.0156" />
            <PreSize X="0.0643" Y="0.1141" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="name" ActionTag="353792706" Tag="54" IconVisible="False" LeftMargin="95.0000" RightMargin="883.0000" TopMargin="582.4594" BottomMargin="29.5406" IsCustomSize="True" FontSize="22" LabelText="玩家名字七个字" VerticalAlignmentType="VT_Center" OutlineEnabled="True" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="158.0000" Y="28.0000" />
            <AnchorPoint ScaleY="0.5000" />
            <Position X="95.0000" Y="43.5406" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="229" G="229" B="229" />
            <PrePosition X="0.0836" Y="0.0680" />
            <PreSize X="0.1391" Y="0.0437" />
            <OutlineColor A="255" R="229" G="229" B="229" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="txt_playerId" ActionTag="1194021837" Tag="35" IconVisible="False" LeftMargin="95.0000" RightMargin="1041.0000" TopMargin="625.0000" BottomMargin="15.0000" FontSize="20" LabelText="" OutlineEnabled="True" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="0.0000" Y="0.0000" />
            <AnchorPoint ScaleY="0.5000" />
            <Position X="95.0000" Y="15.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="229" G="229" B="229" />
            <PrePosition X="0.0836" Y="0.0234" />
            <PreSize X="0.0000" Y="0.0000" />
            <OutlineColor A="255" R="229" G="229" B="229" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_setting" ActionTag="1472072432" Tag="64" IconVisible="False" LeftMargin="268.0000" RightMargin="824.0000" TopMargin="581.0000" BottomMargin="3.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="14" Scale9Height="34" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="44.0000" Y="56.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="290.0000" Y="31.0000" />
            <Scale ScaleX="1.1100" ScaleY="1.1100" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.2553" Y="0.0484" />
            <PreSize X="0.0387" Y="0.0875" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="Normal" Path="image2/hall/btn_shezhi.png" Plist="" />
            <PressedFileData Type="Normal" Path="image2/hall/btn_shezhi.png" Plist="" />
            <NormalFileData Type="Normal" Path="image2/hall/btn_shezhi.png" Plist="" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="shiming_btn" ActionTag="1997134890" Tag="52" IconVisible="False" LeftMargin="323.0000" RightMargin="769.0000" TopMargin="582.0000" BottomMargin="4.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="14" Scale9Height="32" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="44.0000" Y="54.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="345.0000" Y="31.0000" />
            <Scale ScaleX="1.1100" ScaleY="1.1100" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.3037" Y="0.0484" />
            <PreSize X="0.0387" Y="0.0844" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="image2/hall/btn_shiming.png" Plist="image2/hall/hall_2.plist" />
            <PressedFileData Type="MarkedSubImage" Path="image2/hall/btn_shiming.png" Plist="image2/hall/hall_2.plist" />
            <NormalFileData Type="MarkedSubImage" Path="image2/hall/btn_shiming.png" Plist="image2/hall/hall_2.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="cardArea" ActionTag="733527050" Tag="55" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="530.0000" RightMargin="446.0000" TopMargin="587.0000" BottomMargin="7.0000" TouchEnable="True" Scale9Enable="True" LeftEage="50" RightEage="50" Scale9OriginX="50" Scale9Width="60" Scale9Height="46" ctype="ImageViewObjectData">
            <Size X="160.0000" Y="46.0000" />
            <Children>
              <AbstractNodeData Name="Image_8" ActionTag="238882350" Tag="344" IconVisible="False" LeftMargin="-1.3559" RightMargin="121.3559" TopMargin="-2.5114" BottomMargin="9.5114" LeftEage="9" RightEage="9" TopEage="9" BottomEage="9" Scale9OriginX="9" Scale9OriginY="9" Scale9Width="22" Scale9Height="21" ctype="ImageViewObjectData">
                <Size X="40.0000" Y="39.0000" />
                <Children>
                  <AbstractNodeData Name="Image_4" ActionTag="1749524568" Tag="718" IconVisible="False" LeftMargin="28.9555" RightMargin="-8.9555" TopMargin="21.0880" BottomMargin="-2.0880" LeftEage="6" RightEage="6" TopEage="6" BottomEage="6" Scale9OriginX="6" Scale9OriginY="6" Scale9Width="8" Scale9Height="8" ctype="ImageViewObjectData">
                    <Size X="20.0000" Y="20.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="38.9555" Y="7.9120" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.9739" Y="0.2029" />
                    <PreSize X="0.5000" Y="0.5128" />
                    <FileData Type="Normal" Path="image2/common/pic_jingbi_jia.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="18.6441" Y="29.0114" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.1165" Y="0.6307" />
                <PreSize X="0.2500" Y="0.8478" />
                <FileData Type="MarkedSubImage" Path="image2/hall/icon_jinbi.png" Plist="image2/hall/hall_2.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="txt_jinbi" ActionTag="-1188827100" Tag="345" IconVisible="False" LeftMargin="47.1427" RightMargin="48.8573" TopMargin="10.5000" BottomMargin="13.5000" FontSize="19" LabelText="123456" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="64.0000" Y="22.0000" />
                <AnchorPoint ScaleY="0.5000" />
                <Position X="47.1427" Y="24.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="0" />
                <PrePosition X="0.2946" Y="0.5326" />
                <PreSize X="0.4000" Y="0.4783" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleY="0.5000" />
            <Position X="530.0000" Y="30.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.4665" Y="0.0469" />
            <PreSize X="0.1408" Y="0.0719" />
            <FileData Type="MarkedSubImage" Path="image2/hall/fk_bg.png" Plist="image2/hall/hall_2.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="cardArea_2" ActionTag="-1438488024" Tag="71" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="372.0000" RightMargin="604.0000" TopMargin="587.0000" BottomMargin="7.0000" TouchEnable="True" Scale9Enable="True" LeftEage="50" RightEage="50" Scale9OriginX="50" Scale9Width="60" Scale9Height="46" ctype="ImageViewObjectData">
            <Size X="160.0000" Y="46.0000" />
            <Children>
              <AbstractNodeData Name="Image_8" ActionTag="-2038230056" Tag="74" IconVisible="False" LeftMargin="11.8489" RightMargin="120.1511" TopMargin="6.1672" BottomMargin="7.8328" LeftEage="9" RightEage="9" TopEage="9" BottomEage="9" Scale9OriginX="9" Scale9OriginY="9" Scale9Width="10" Scale9Height="14" ctype="ImageViewObjectData">
                <Size X="28.0000" Y="32.0000" />
                <Children>
                  <AbstractNodeData Name="Image_3" ActionTag="509771348" Tag="717" IconVisible="False" LeftMargin="16.9010" RightMargin="-8.9010" TopMargin="12.9012" BottomMargin="-0.9012" LeftEage="6" RightEage="6" TopEage="6" BottomEage="6" Scale9OriginX="6" Scale9OriginY="6" Scale9Width="8" Scale9Height="8" ctype="ImageViewObjectData">
                    <Size X="20.0000" Y="20.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="26.9010" Y="9.0988" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.9607" Y="0.2843" />
                    <PreSize X="0.7143" Y="0.6250" />
                    <FileData Type="Normal" Path="image2/common/pic_fangka_jia.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="25.8489" Y="23.8328" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.1616" Y="0.5181" />
                <PreSize X="0.1750" Y="0.6957" />
                <FileData Type="MarkedSubImage" Path="image2/hall/icon_fangka.png" Plist="image2/hall/hall_2.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="card" ActionTag="885563064" Tag="72" IconVisible="False" LeftMargin="46.5384" RightMargin="49.4616" TopMargin="10.5000" BottomMargin="13.5000" FontSize="19" LabelText="123456" VerticalAlignmentType="VT_Center" OutlineEnabled="True" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="64.0000" Y="22.0000" />
                <AnchorPoint ScaleY="0.5000" />
                <Position X="46.5384" Y="24.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="192" B="203" />
                <PrePosition X="0.2909" Y="0.5326" />
                <PreSize X="0.4000" Y="0.4783" />
                <OutlineColor A="255" R="255" G="91" B="1" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleY="0.5000" />
            <Position X="372.0000" Y="30.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.3275" Y="0.0469" />
            <PreSize X="0.1408" Y="0.0719" />
            <FileData Type="MarkedSubImage" Path="image2/hall/fk_bg.png" Plist="image2/hall/hall_2.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_quickCreateRoom" ActionTag="961824669" Tag="61" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="810.0000" TopMargin="548.0000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="296" Scale9Height="70" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="326.0000" Y="92.0000" />
            <Children>
              <AbstractNodeData Name="Image_1" ActionTag="-953028211" Tag="62" IconVisible="False" LeftMargin="104.9177" RightMargin="65.0823" TopMargin="24.6765" BottomMargin="5.3235" LeftEage="51" RightEage="51" TopEage="20" BottomEage="20" Scale9OriginX="51" Scale9OriginY="20" Scale9Width="54" Scale9Height="22" ctype="ImageViewObjectData">
                <Size X="156.0000" Y="62.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="182.9177" Y="36.3235" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5611" Y="0.3948" />
                <PreSize X="0.4785" Y="0.6739" />
                <FileData Type="Normal" Path="image2/hall/pic_kuaisukaifang.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_2" ActionTag="-608431711" Tag="63" IconVisible="False" LeftMargin="263.4055" RightMargin="18.5945" TopMargin="27.0000" BottomMargin="25.0000" LeftEage="14" RightEage="14" TopEage="13" BottomEage="13" Scale9OriginX="14" Scale9OriginY="13" Scale9Width="16" Scale9Height="14" ctype="ImageViewObjectData">
                <Size X="44.0000" Y="40.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="285.4055" Y="45.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.8755" Y="0.4891" />
                <PreSize X="0.1350" Y="0.4348" />
                <FileData Type="Normal" Path="image2/hall/pic_kuaisukaifang_2.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="1.0000" />
            <Position X="1136.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="1.0000" />
            <PreSize X="0.2870" Y="0.1437" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="Normal" Path="image2/hall/btn_kuaisukaifang.png" Plist="" />
            <PressedFileData Type="Normal" Path="image2/hall/btn_kuaisukaifang.png" Plist="" />
            <NormalFileData Type="Normal" Path="image2/hall/btn_kuaisukaifang.png" Plist="" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="btn_buy" ActionTag="686644881" Tag="57" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="683.5000" RightMargin="299.5000" TopMargin="574.2244" BottomMargin="-0.2244" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="123" Scale9Height="44" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="153.0000" Y="66.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="760.0000" Y="32.7756" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.6690" Y="0.0512" />
            <PreSize X="0.1347" Y="0.1031" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="MarkedSubImage" Path="image2/hall/btn_chongzhi.png" Plist="image2/hall/hall_2.plist" />
            <PressedFileData Type="MarkedSubImage" Path="image2/hall/btn_chongzhi.png" Plist="image2/hall/hall_2.plist" />
            <NormalFileData Type="MarkedSubImage" Path="image2/hall/btn_chongzhi.png" Plist="image2/hall/hall_2.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>