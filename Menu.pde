import apwidgets.*;
import android.text.InputType;
import android.view.inputmethod.EditorInfo;

PWidgetContainer FWidgetContainer; 
PEditText FIPField;
PEditText FPortField;
PButton FOKButton;
PCheckBox FStickySlider;
PCheckBox FShowModifier;
PCheckBox FShowLabels;
PCheckBox FShowValues;
PCheckBox FSendTouches;
PCheckBox FSendAcceleration;
PCheckBox FSendOrientation;
PCheckBox FSendMagneticField;
PCheckBox FSendLocation;

boolean FMenuVisible = false;
boolean FTargetChanged = true;

void initMenu()
{
  int col2x = width - 245;
  FWidgetContainer = new PWidgetContainer(this);

  FIPField = new PEditText(col2x, 180, 230, 70);
  FIPField.setText(getTargetIP());
  FIPField.setImeOptions(EditorInfo.IME_ACTION_DONE);
  FIPField.setInputType(InputType.TYPE_CLASS_PHONE);
  FIPField.setCloseImeOnDone(true);
  FWidgetContainer.addWidget(FIPField); 
  
  FPortField = new PEditText(col2x, 250, 150, 70);
  FPortField.setText("44444");
  FPortField.setInputType(InputType.TYPE_CLASS_NUMBER);
  FPortField.setImeOptions(EditorInfo.IME_ACTION_DONE);
  FPortField.setCloseImeOnDone(true);
  FWidgetContainer.addWidget(FPortField); 
 
  FStickySlider = new PCheckBox(15, 330, "Sticky Slider");
  FWidgetContainer.addWidget(FStickySlider);
  
  FShowModifier = new PCheckBox(col2x, 330, "Show Modifier");
  FWidgetContainer.addWidget(FShowModifier);
  
  FShowLabels = new PCheckBox(15, 400, "Show Labels");
  FShowLabels.setChecked(true);
  FWidgetContainer.addWidget(FShowLabels);
  
  FShowValues = new PCheckBox(col2x, 400, "Show Values");
  FShowValues.setChecked(true);
  FWidgetContainer.addWidget(FShowValues);
 
 
  FSendTouches = new PCheckBox(15, 540, "Touches");
  FSendTouches.setChecked(true);
  FWidgetContainer.addWidget(FSendTouches);
  
  FSendMagneticField = new PCheckBox(col2x, 540, "Magnetic Field");
  FWidgetContainer.addWidget(FSendMagneticField);
  
  FSendAcceleration = new PCheckBox(15, 620, "Acceleration");
  FWidgetContainer.addWidget(FSendAcceleration);
  
  FSendOrientation = new PCheckBox(col2x, 620, "Orientation");
  FWidgetContainer.addWidget(FSendOrientation);

  FSendLocation = new PCheckBox(15, 700, "Location");
  FWidgetContainer.addWidget(FSendLocation);

  FOKButton = new PButton(15, height - 90, 150, 70, "Save");
  FWidgetContainer.addWidget(FOKButton);
  FWidgetContainer.hide();
}

void onClickWidget(PWidget widget)
{
  if(widget == FOKButton)
  {
    saveSettings();
    toggleMenu();  
  }
  else if (widget == FIPField)
    FTargetChanged = true;
  else if (widget == FPortField)
    FTargetChanged = true;
  else if (widget == FShowModifier)
  {
    if (FShowModifier.isChecked())
      GValueTop = CModifierPanelHeight;
    else
      GValueTop = 0;
  }
}

void toggleMenu()
{
  if (FMenuVisible)
  {
    FWidgetContainer.hide();
    if (FTargetChanged)
    {
      initNetwork();
      FTargetChanged = false;
    }
    reset();
    FMenuVisible = false;
  }
  else
  {
    FWidgetContainer.show();
    FMenuVisible = true;
  }
}

void drawMenu()
{
  fill(255);
  textAlign(LEFT);
  textFont(fontB, 48);
  text("Kontrolleur", 15, 60); 
  textFont(fontA, 24);
  text(CVersion, width-170, 60); 
  
  text("IP & Port: " + FLocalIP + ":" + FLocalPort, 15, 110); 
  text("Screen Resolution: " + width + "x" + height, 15, 150); 

  text("Target IP Address", 15, 220); 
  text("Target UDP Port", 15, 290); 
  
  text("Send", 15, 520); 
}

void reset()
{
  //println("-----update-----");

  synchronized(this)
  {
    FRemoteValues.clear();
  }
  
  OscBundle bundle = new OscBundle();
  OscMessage m = new OscMessage("/k/init");
  m.add(FLocalIP);
  m.add(FLocalPort);
  m.add(width);
  m.add(height);
  bundle.add(m);
  sendBundle(bundle);
}
