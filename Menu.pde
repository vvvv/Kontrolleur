import apwidgets.*;
import android.text.InputType;
import android.view.inputmethod.EditorInfo;

PWidgetContainer FWidgetContainer; 
PEditText FIPField;
PEditText FPortField;
PButton FOKButton;
PCheckBox FStickySlider;
PCheckBox FShowLabels;
PCheckBox FShowValues;
PCheckBox FSendTouches;
PCheckBox FSendAcceleration;
PCheckBox FSendOrientation;
PCheckBox FSendMagneticField;

boolean FMenuVisible = false;
boolean FTargetChanged = true;

void initMenu()
{
  FWidgetContainer = new PWidgetContainer(this);

  FIPField = new PEditText(20, 110, 230, 70);
  FIPField.setText("192.168.0.255");
  FIPField.setImeOptions(EditorInfo.IME_ACTION_DONE);
  FIPField.setCloseImeOnDone(true);
  FWidgetContainer.addWidget(FIPField); 
  
  FPortField = new PEditText(20, 180, 150, 70);
  FPortField.setText("4444");
  FPortField.setInputType(InputType.TYPE_CLASS_NUMBER);
  FPortField.setImeOptions(EditorInfo.IME_ACTION_DONE);
  FPortField.setCloseImeOnDone(true);
  FWidgetContainer.addWidget(FPortField); 
 
  FStickySlider = new PCheckBox(20, 250, "Sticky Slider");
  FWidgetContainer.addWidget(FStickySlider);
  
  FShowLabels = new PCheckBox(20, 320, "Show Labels");
  FShowLabels.setChecked(true);
  FWidgetContainer.addWidget(FShowLabels);
  
  FShowValues = new PCheckBox(20, 390, "Show Values");
  FShowValues.setChecked(true);
  FWidgetContainer.addWidget(FShowValues);
 
  FSendTouches = new PCheckBox(20, 460, "Send Touches");
  FSendTouches.setChecked(true);
  FWidgetContainer.addWidget(FSendTouches);
  
  FSendAcceleration = new PCheckBox(20, 530, "Send Acceleration");
  FWidgetContainer.addWidget(FSendAcceleration);
  
  FSendOrientation = new PCheckBox(20, 600, "Send Orientation");
  FWidgetContainer.addWidget(FSendOrientation);
  
  FSendMagneticField = new PCheckBox(20, 670, "Send Magnetic Field");
  FWidgetContainer.addWidget(FSendMagneticField);

  FOKButton = new PButton(20, height - 100, 150, 70, "OK");
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
}

void toggleMenu()
{
  if (FMenuVisible)
  {
    FWidgetContainer.hide();
    FMenuVisible = false;
    if (FTargetChanged)
    {
      initNetwork();
      FTargetChanged = false;
    }
    reset();
  }
  else
  {
    FWidgetContainer.show();
    FMenuVisible = true;
  }
}

void reset()
{
  println("-----update-----");
  
  OscBundle bundle = new OscBundle();
  OscMessage message = new OscMessage("/k/reset");
  bundle.add(message);
  sendBundle(bundle);

  synchronized(this)
  {
    FRemoteValues.clear();
  }
}
