package processing.android.test.kontrolleur;

import processing.core.*; 
import processing.xml.*; 

import controlP5.*; 
import oscP5.*; 
import netP5.*; 
import java.net.InetAddress; 

import controlP5.*; 
import oscP5.*; 
import netP5.*; 

import android.view.MotionEvent; 
import android.view.KeyEvent; 
import android.graphics.Bitmap; 
import java.io.*; 
import java.util.*; 

public class Kontrolleur extends PApplet {






//todo
//- reset (request full resend/init)
//- distinguish between toggle, bang, slider, endless
//- support spreads
//- multiple pages (one per address-space)
//- deal with screen rotation
//- discover/send/display phone ip
//- multitouch

OscP5 oscP5;
NetAddress FTargetNetAddress;
String FTargetIP = "localhost";//192.168.2.181";
int FTargetPort = 5556;
int FKontrollerPort = 5555;

String GIP;
int GValueHeight = height;
PFont fontA;
HashMap<String, RemoteValue> FRemoteValues;
int FActiveValue = -1;

//ControlP5 controlP5;

public void setup() 
{
 
  orientation(PORTRAIT);
//  frameRate(25);
  oscP5 = new OscP5(this, FKontrollerPort);
  FTargetNetAddress = new NetAddress(FTargetIP, FTargetPort);
  
  FRemoteValues = new HashMap<String, RemoteValue>();
  
  fontA = loadFont("Verdana-12.vlw");
  textFont(fontA, 12);
  
  //read device IP
  try 
  {
    InetAddress inet = InetAddress.getLocalHost();
    GIP = inet.getHostAddress();
  }
  catch (Exception e) 
  {
    e.printStackTrace();
    GIP = "couldnt get IP";
  }
  
  //request init
  reset();
  
  //seems not to work on android yet
  //controlP5 = new ControlP5(this);
  //controlP5.addButton("reset", 0, width-60, 0, 60, 40);
}

public void draw() 
{
  background(230);  
  
  //display all values and add message to the bundle if changed
  OscBundle bundle = new OscBundle();
  for(String key: FRemoteValues.keySet())
  {
    RemoteValue rm = (RemoteValue) FRemoteValues.get(key);
    rm.display();
    rm.addMessage(bundle);
  }
    
  //only send bundle if it contains messages
  if (bundle.size() > 0)
  {
    bundle.setTimetag(bundle.now() + 10000);
    oscP5.send(bundle, FTargetNetAddress);
  }
  
  stroke(128);
  text(GIP, width - 100, height - 10);
}

public void keyPressed()
{
  if (key == CODED)
  {
   // if (keyCode == MENU)
    {
      reset();
    }
  }
}

//public void reset(int theValue) 
//{
//  reset();
//}

public void reset()
{
  OscBundle bundle = new OscBundle();
  OscMessage message = new OscMessage("/kontrolleur/reset");
  bundle.add(message);
  bundle.setTimetag(bundle.now() + 10000);
  oscP5.send(bundle, FTargetNetAddress);
}

public void mouseDragged()
{
  FActiveValue = mouseY / GValueHeight;

  //update the active value
  for(String key: FRemoteValues.keySet() )
  {
    RemoteValue rm = (RemoteValue) FRemoteValues.get(key);
    if (rm.ID == FActiveValue)
    {
      rm.changeValue(mouseX);
      break;
    }
  }
}

public void mouseReleased()
{
  FActiveValue = -1;
}

public void oscEvent(OscMessage message) 
{
  //println(message.addrPattern());
  
  //only accept specific messages
  if (!((message.checkAddrPattern("/kontrolleur/add")) 
  || (message.checkAddrPattern("/kontrolleur/update"))
  || (message.checkAddrPattern("/kontrolleur/remove"))))
    return;

  String address = message.get(0).stringValue();
  address = address.trim();
  String name = "";
  float minimum = 0;
  float maximum = 1;
  float value = 0;
  
  //read arguments if tjis is an add or update message
  if ((message.checkAddrPattern("/kontrolleur/add")) 
  || (message.checkAddrPattern("/kontrolleur/update")))
  {
    name = message.get(1).stringValue();
    minimum = message.get(2).floatValue();
    maximum = message.get(3).floatValue();
    value = message.get(4).floatValue();
  }
    
  if (message.checkAddrPattern("/kontrolleur/add")) 
  { 
    if (!FRemoteValues.containsKey(address))
    {
      int id = FRemoteValues.size();
      RemoteValue rm = new RemoteValue(id, address, name, minimum, maximum, value);
      FRemoteValues.put(address, rm);
    }
  }
  else if (message.checkAddrPattern("/kontrolleur/update"))
  {
    RemoteValue rm = (RemoteValue) FRemoteValues.get(address);
    if (rm.ID != FActiveValue)
    {
      rm.Name = name;
      rm.Minimum = minimum;
      rm.Maximum = maximum;
      rm.Value = value;
    }
  }   
  else if (message.checkAddrPattern("/kontrolleur/remove"))
  {
    if (FRemoteValues.containsKey(address))
    {
      FRemoteValues.remove(address);
      
      //update IDs of all remotevalues
      int i = 0;
      for(String key: FRemoteValues.keySet())
      {
        RemoteValue rm = (RemoteValue) FRemoteValues.get(key);
        rm.ID = i;
        i++;
      }
    }  
  }
  
  //recompute the values height
  GValueHeight = height / FRemoteValues.size();
}
class RemoteValue 
{
  public int ID;
  String FAddress;
  public String Name;
  public float Minimum;
  public float Maximum;
  public float Value;  
  boolean FValueChanged;
  
  RemoteValue(int id, String address, String name, float minimum, float maximum, float value)
  {
    ID = id;
    FAddress = address;
    Name = name;
    Minimum = minimum;
    Maximum = maximum;
    Value = value;
  }
  
  public void addMessage(OscBundle bundle) 
  {
    if (FValueChanged)
    {
      OscMessage m = new OscMessage(FAddress);
      m.add(Value);
      bundle.add(m);
      FValueChanged = false;
    }
  }
  
  public void changeValue(float x)
  {
    Value = map(x, 0, width, Minimum, Maximum);
    FValueChanged = true;
  }
 
  public void display() 
  {
    fill(128);
    noStroke();
    
    float x = map(Value, Minimum, Maximum, 0, width);
    rect(x, ID * GValueHeight, 50, GValueHeight);
    
    fill(0);
    text(Name, 13, ID * GValueHeight + 15);
    text(Value, 10, ID * GValueHeight + 35);
  }
}

  public int sketchWidth() { return 480; }
  public int sketchHeight() { return 854; }
}
