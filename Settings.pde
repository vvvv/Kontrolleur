import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;

String CSaveFile = "kontrolleur.xml";
String CSaveTag = "KONTROLLEUR";
String CNoNetwork = "no network found!";

void saveSettings()
{
  XML settings = new XML(CSaveTag);
  settings.setString("IP", FIPField.getText());
  
  settings.setString("Port", FPortField.getText());
  settings.setInt("StickySlider", int(FStickySlider.isChecked()));
  settings.setInt("ShowModifier", int(FShowModifier.isChecked()));
  settings.setInt("ShowLabels", int(FShowLabels.isChecked()));
  settings.setInt("ShowValues", int(FShowValues.isChecked()));
  settings.setInt("SendTouches", int(FSendTouches.isChecked()));
  settings.setInt("SendAcceleration", int(FSendAcceleration.isChecked()));
  settings.setInt("SendOrientation", int(FSendOrientation.isChecked()));
  settings.setInt("SendMagneticField", int(FSendMagneticField.isChecked()));
  
  PrintWriter pw = createWriter(CSaveFile);
  settings.save(pw);
}

boolean loadSettings()
{
  BufferedReader br = createReader(CSaveFile);

  try 
  {
    XML settings = new XML(br);

    FIPField.setText(settings.getString("IP", getTargetIP()));
    FPortField.setText(settings.getString("Port", "44444"));
    FStickySlider.setChecked(boolean(settings.getInt("StickySlider", 0)));
    FShowModifier.setChecked(boolean(settings.getInt("ShowModifier", 0)));
    FShowLabels.setChecked(boolean(settings.getInt("ShowLabels", 1)));
    FShowValues.setChecked(boolean(settings.getInt("ShowValues", 1)));
    FSendTouches.setChecked(boolean(settings.getInt("SendTouches", 1)));
    FSendAcceleration.setChecked(boolean(settings.getInt("SendAcceleration", 0)));
    FSendOrientation.setChecked(boolean(settings.getInt("SendOrientation", 0)));
    FSendMagneticField.setChecked(boolean(settings.getInt("SendMagneticField", 0)));
    
    if (FShowModifier.isChecked())
      GValueTop = CModifierPanelHeight;
    else
      GValueTop = 0;
    
    return (settings.getAttributeCount() > 0);
  } 
  catch (Exception e) 
  {
    return false;
  }
}
