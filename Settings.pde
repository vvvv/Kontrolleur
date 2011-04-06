import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;

String CSaveFile = "kontrolleur.xml";
String CSaveTag = "KONTROLLEUR";
String CNoNetwork = "no network found!";

void saveSettings()
{
  XMLElement settings = new XMLElement(CSaveTag);
  
  settings.setString("IP", FIPField.getText());
  settings.setString("Port", FPortField.getText());
  settings.setBoolean("StickySlider", FStickySlider.isChecked());
  settings.setBoolean("ShowModifier", FShowModifier.isChecked());
  settings.setBoolean("ShowLabels", FShowLabels.isChecked());
  settings.setBoolean("ShowValues", FShowValues.isChecked());
  settings.setBoolean("SendTouches", FSendTouches.isChecked());
  settings.setBoolean("SendAcceleration", FSendAcceleration.isChecked());
  settings.setBoolean("SendOrientation", FSendOrientation.isChecked());
  settings.setBoolean("SendMagneticField", FSendMagneticField.isChecked());
  
  PrintWriter pw = createWriter(CSaveFile);
  settings.write(pw);
}

boolean loadSettings()
{
  BufferedReader br = createReader(CSaveFile);

  try 
  {
    XMLElement settings = XMLElement.parse(br);
    FIPField.setText(settings.getString("IP", getTargetIP()));
    //hack: after setting IP make this a numberfield
    FIPField.setInputType(InputType.TYPE_CLASS_NUMBER);
    
    FPortField.setText(settings.getString("Port", "4444"));
    FStickySlider.setChecked(settings.getBoolean("StickySlider", false));
    FShowModifier.setChecked(settings.getBoolean("ShowModifier", false));
    FShowLabels.setChecked(settings.getBoolean("ShowLabels", true));
    FShowValues.setChecked(settings.getBoolean("ShowValues", true));
    FSendTouches.setChecked(settings.getBoolean("SendTouches", true));
    FSendAcceleration.setChecked(settings.getBoolean("SendAcceleration", false));
    FSendOrientation.setChecked(settings.getBoolean("SendOrientation", false));
    FSendMagneticField.setChecked(settings.getBoolean("SendMagneticField", false));
    
    if (FShowModifier.isChecked())
      GValueTop = CModifierPanelHeight;
    else
      GValueTop = 0;
    
    return (settings.getAttributeCount() > 0);
  } 
  catch (NullPointerException e) 
  {
    //hack: after setting IP make this a numberfield
    FIPField.setInputType(InputType.TYPE_CLASS_NUMBER);
    return false;
  }
}
