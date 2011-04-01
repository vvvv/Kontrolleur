class RemoteValue
{
  public int ID;
  String FAddress;
  public String Name;
  public float Minimum;
  public float Maximum;
  public float Value;  
  protected boolean FValueChanged;
  protected boolean FMouseDown = false;
  protected int FSliderWidth = 50;
  protected float FSliderY;
  protected float FTextY;
  protected float FLastX;
  protected float FButtonHeight;
  protected float FButtonWidth;
  protected float FButtonX;
  protected float FButtonY;
  
  RemoteValue(int id, String address, String name, float minimum, float maximum, float value)
  {
    ID = id;
    FAddress = address;
    Name = name;
    Minimum = minimum;
    Maximum = maximum;
    Value = value;
  }
  
  void addMessage(OscBundle bundle) 
  {
    if (FValueChanged)
    {
      OscMessage m = new OscMessage("/k" + FAddress);
      addOSCValue(m);
      bundle.add(m);
      
      FValueChanged = false;
    }
  }
  
  void addOSCValue(OscMessage message) 
  {
     message.add(Value);
  }
  
  void changeValue(float x)
  {}
  
  void releaseMouse()
  {
    FMouseDown = false;
  }
 
  void paint() 
  {
    fill(CBright);

    float y = GValueTop + ID * GValueHeight;
    FSliderY = y + 3;
    FTextY = y + GValueHeight - 20;

    FButtonHeight = max(GValueHeight / 3, FSliderWidth);
    FButtonWidth = width / 3;
    FButtonX = width / 2 - FButtonWidth / 2;
    FButtonY = y + GValueHeight / 2 - FButtonHeight / 2;
  }
  
  void paintLabel()
  {
    if (FShowLabels.isChecked())
    {
      fill(0);
      textAlign(LEFT);
      text(Name, 15, FTextY);    
    }
  }
  
  void paintValue()
  {
    if (FShowValues.isChecked())
    {
      fill(0);
      textAlign(RIGHT);
      text(String.format("%.4f", Value), width - 15, FTextY);
    }
  }
}

class RemoteSlider extends RemoteValue
{
  float FStepSize; 
  
  RemoteSlider(int id, String address, String name, float minimum, float maximum, float stepsize, float value)
  {
    super(id, address, name, minimum, maximum, value);
    FStepSize = stepsize;
  }
  
  void changeValue(float x)
  {
    Value = map(x, 0, width, Minimum, Maximum);
    FValueChanged = true;
  }
  
  void paint()
  {
    super.paint();
    
    noStroke();
    float x = map(Value, Minimum, Maximum, 0, width) - FSliderWidth/2;
    rect(x, FSliderY, FSliderWidth, GValueHeight-6);
    
    paintLabel();
    paintValue();
  }
}

class RemoteEndless extends RemoteValue
{
  float FStepSize; 
  
  RemoteEndless(int id, String address, String name, float minimum, float maximum, float stepsize, float value)
  {
    super(id, address, name, minimum, maximum, value);
    FStepSize = stepsize;
  }
  
  void changeValue(float x)
  {
    if (!FMouseDown)
      FMouseDown = true;
    else
    {
      int steps = (int) (x - FLastX);
      Value += steps * FStepSize * FModifier;
      FValueChanged = true;
      FLastX = x;
    }
    
    FLastX = x;
  }
  
  void paint()
  {
    super.paint();
    noStroke();
    int count = 20;
    for (int i = 0; i < count; i++)
    {
      float x = (FLastX + (width/count) * i) % width;
      rect(x, FSliderY, 2, GValueHeight-6);
    }      
    
    paintLabel();
    paintValue();    
  }
}

class RemoteBang extends RemoteValue
{
  RemoteBang(int id, String address, String name, float minimum, float maximum, float value)
  {
    super(id, address, name, minimum, maximum, value);
  }
  
  void changeValue(float x)
  {
    if (!FMouseDown)
    {
      Value = Maximum;
      FValueChanged = true;
      FMouseDown = true;
    }
  }
  
  void addOSCValue(OscMessage message) 
  {
     message.add("bang");
  } 
  
  void paint()
  {
    super.paint();
    
    stroke(128);
    strokeWeight(2);
    if (Value != Maximum)
      noFill();     
    Value = Minimum;
    rect(FButtonX, FButtonY, FButtonWidth, FButtonHeight);
  
    paintLabel();
  } 
}

class RemoteToggle extends RemoteValue
{
  RemoteToggle(int id, String address, String name, float minimum, float maximum, float value)
  {
    super(id, address, name, minimum, maximum, value);
  }
  
  void changeValue(float x)
  {
    if (!FMouseDown)
    {
      if (Value == Minimum)
        Value = Maximum;
      else
        Value = Minimum;    

      FValueChanged = true;
      FMouseDown = true;
    }    
  }
  
  void paint()
  {
    super.paint();

    stroke(128);
    strokeWeight(2);
    if (Value != Maximum)
      noFill();        
    rect(FButtonX, FButtonY, FButtonWidth, FButtonHeight);

    paintLabel();
  } 
}
