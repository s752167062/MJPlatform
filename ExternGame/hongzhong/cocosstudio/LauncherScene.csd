<GameFile>
  <PropertyGroup Name="LauncherScene" Type="Scene" ID="2f87fd9d-1fc1-41ab-9a24-dac1ef92657f" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Scene_Launcher" ctype="GameNodeObjectData">
        <Size X="1136.0000" Y="640.0000" />
        <Children>
          <AbstractNodeData Name="bg" ActionTag="-1202640112" Tag="11" IconVisible="False" HorizontalEdge="BothEdge" VerticalEdge="BothEdge" StretchWidthEnable="True" StretchHeightEnable="True" LeftEage="316" RightEage="316" TopEage="178" BottomEage="178" Scale9OriginX="316" Scale9OriginY="178" Scale9Width="392" Scale9Height="220" ctype="ImageViewObjectData">
            <Size X="1136.0000" Y="640.0000" />
            <Children>
              <AbstractNodeData Name="update" ActionTag="1713078806" Tag="12" IconVisible="False" HorizontalEdge="BothEdge" VerticalEdge="BothEdge" LeftMargin="466.0000" RightMargin="466.0000" TopMargin="495.0160" BottomMargin="114.9840" LeftEage="67" RightEage="67" TopEage="9" BottomEage="9" Scale9OriginX="67" Scale9OriginY="9" Scale9Width="70" Scale9Height="12" ctype="ImageViewObjectData">
                <Size X="204.0000" Y="30.0000" />
                <Children>
                  <AbstractNodeData Name="updateLoadingBar" ActionTag="108877017" Tag="13" IconVisible="False" LeftMargin="1.0000" RightMargin="1.0000" TopMargin="3.0000" BottomMargin="3.0000" ProgressInfo="100" ctype="LoadingBarObjectData">
                    <Size X="202.0000" Y="24.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="102.0000" Y="15.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.5000" />
                    <PreSize X="0.9902" Y="0.8000" />
                    <ImageFileData Type="PlistSubImage" Path="loginUI_progressBarHead.png" Plist="image/ui_login.plist" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="568.0000" Y="129.9840" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.2031" />
                <PreSize X="0.1796" Y="0.0469" />
                <FileData Type="PlistSubImage" Path="loginUI_progressBarBg.png" Plist="image/ui_login.plist" />
              </AbstractNodeData>
              <AbstractNodeData Name="tips" ActionTag="-785485291" Tag="14" IconVisible="False" HorizontalEdge="BothEdge" VerticalEdge="BothEdge" LeftMargin="538.0000" RightMargin="538.0000" TopMargin="536.9920" BottomMargin="79.0080" FontSize="20" LabelText="更新..." HorizontalAlignmentType="HT_Center" VerticalAlignmentType="VT_Center" OutlineEnabled="True" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="60.0000" Y="24.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="568.0000" Y="91.0080" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="116" G="42" B="14" />
                <PrePosition X="0.5000" Y="0.1422" />
                <PreSize X="0.0528" Y="0.0375" />
                <FontResource Type="Normal" Path="font/LexusJianHei.TTF" Plist="" />
                <OutlineColor A="255" R="255" G="255" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="568.0000" Y="320.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <FileData Type="Normal" Path="logo.jpg" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="Text_1" ActionTag="199302737" Tag="179" IconVisible="False" LeftMargin="24.0000" RightMargin="992.0000" TopMargin="15.5000" BottomMargin="601.5000" FontSize="20" LabelText="服务器版本：" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="120.0000" Y="23.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="84.0000" Y="613.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="26" G="26" B="26" />
            <PrePosition X="0.0739" Y="0.9578" />
            <PreSize X="0.1056" Y="0.0359" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="Text_2" ActionTag="-219249896" Tag="180" IconVisible="False" LeftMargin="24.0000" RightMargin="1012.0000" TopMargin="41.8333" BottomMargin="575.1667" FontSize="20" LabelText="当前版本：" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="100.0000" Y="23.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="74.0000" Y="586.6667" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="26" G="26" B="26" />
            <PrePosition X="0.0651" Y="0.9167" />
            <PreSize X="0.0880" Y="0.0359" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="Text_3" ActionTag="858118063" Tag="182" IconVisible="False" LeftMargin="24.0000" RightMargin="1012.0000" TopMargin="68.1666" BottomMargin="548.8334" FontSize="20" LabelText="目标版本：" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="100.0000" Y="23.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="74.0000" Y="560.3334" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="26" G="26" B="26" />
            <PrePosition X="0.0651" Y="0.8755" />
            <PreSize X="0.0880" Y="0.0359" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="target_version" ActionTag="-1568565312" Tag="181" IconVisible="False" LeftMargin="151.0000" RightMargin="785.0000" TopMargin="68.1666" BottomMargin="548.8334" IsCustomSize="True" FontSize="20" LabelText="无" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="200.0000" Y="23.0000" />
            <AnchorPoint ScaleY="0.5000" />
            <Position X="151.0000" Y="560.3334" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="26" G="26" B="26" />
            <PrePosition X="0.1329" Y="0.8755" />
            <PreSize X="0.1761" Y="0.0359" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="cur_version" ActionTag="766248890" Tag="183" IconVisible="False" LeftMargin="151.0000" RightMargin="785.0000" TopMargin="41.8333" BottomMargin="575.1667" IsCustomSize="True" FontSize="20" LabelText="无" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="200.0000" Y="23.0000" />
            <AnchorPoint ScaleY="0.5000" />
            <Position X="151.0000" Y="586.6667" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="26" G="26" B="26" />
            <PrePosition X="0.1329" Y="0.9167" />
            <PreSize X="0.1761" Y="0.0359" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="server_version" ActionTag="-487553395" Tag="184" IconVisible="False" LeftMargin="151.0000" RightMargin="785.0000" TopMargin="15.5000" BottomMargin="601.5000" IsCustomSize="True" FontSize="20" LabelText="无" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="200.0000" Y="23.0000" />
            <AnchorPoint ScaleY="0.5000" />
            <Position X="151.0000" Y="613.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="26" G="26" B="26" />
            <PrePosition X="0.1329" Y="0.9578" />
            <PreSize X="0.1761" Y="0.0359" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>
