float FModifier = 1;
int FModifierID = -1;
int ACTION_POINTER_INDEX_SHIFT = 8;
int ACTION_POINTER_INDEX_MASK = 65280;

class Touch 
{
  float motionX, motionY;
  float Pressure;
  int PointerID;
  int RemoteValueID;
  boolean Touched = false;
  
  Touch(MotionEvent me, int index, int remoteValueID)
  {
    RemoteValueID = remoteValueID;
    motionX = me.getX(index);
    motionY = me.getY(index);
    Pressure = me.getPressure(index) * 200;

    PointerID = me.getPointerId(index);
    Touched = true;
  }
  
  void update(MotionEvent me, int index)
  {
    motionX = me.getX(index);
    motionY = me.getY(index);
    Pressure = me.getPressure(index) * 200;

    PointerID = me.getPointerId(index);
    Touched = true;
  }
  
  void unTouch()
  {
    Touched = false;
  }
  
  void addMessage(OscBundle bundle) 
  {
    OscMessage m = new OscMessage("/touch/" + Integer.toString(PointerID));
    m.add(motionX);
    m.add(motionY);
    m.add(Pressure);
    bundle.add(m);
  }
  
  void paint()
  {
    float r = Pressure + 40; 
    ellipse(motionX, motionY, r, r);
    text(Integer.toString(PointerID), motionX-5, motionY - (Pressure+50));
  }
}

//------------------------------
// Override parent class's surfaceTouchEvent() method to enable multi-touch.
// This is what grabs the Android multitouch data, and feeds our MultiTouch
// classes. Only executes on touch change (movement across screen, or initial
// touch).

public boolean surfaceTouchEvent(MotionEvent me) 
{  
  //invalidate touches
  for(Integer key: FTouches.keySet())
  {
    Touch t = FTouches.get(key);
    t.unTouch();
  }
  
  int action = me.getAction();
  int event = action & MotionEvent.ACTION_MASK;
  int pointerIndex = 0;
  int pointerID = 0;
  int remoteValueID = -1; //= modifier
  int y = 0;
  
  switch (event) 
  {
    //first pointer down
    case MotionEvent.ACTION_DOWN: {pointerIndex = 0; break;}
    //other than first pointer down
    case MotionEvent.ACTION_POINTER_DOWN: {pointerIndex = (action & ACTION_POINTER_INDEX_MASK) >> ACTION_POINTER_INDEX_SHIFT; break;}
    //last pointer up
    case MotionEvent.ACTION_UP: {pointerIndex = 0; break;}
    //other than last pointer up
    case MotionEvent.ACTION_POINTER_UP: {pointerIndex = (action & ACTION_POINTER_INDEX_MASK) >> ACTION_POINTER_INDEX_SHIFT; break;}
    //pointers moving
    case MotionEvent.ACTION_MOVE:
    {
      //update touches
      int pointerCount = me.getPointerCount();
      for (int i = 0; i < pointerCount; i++)
      {
        y = (int) me.getY(i);
        if (y > GValueTop)
          remoteValueID = (int) ((y - GValueTop) / GValueHeight);
        pointerID = me.getPointerId(i);
        
        if (FTouches.containsKey(pointerID))
        {
          Touch t = FTouches.get(pointerID);
          t.update(me, i);
         
          int oldRemoteValueID = t.RemoteValueID;
          if ((oldRemoteValueID != remoteValueID) 
          && (oldRemoteValueID != -1) 
          && !FStickySlider.isChecked())
          {
            FTouchedValues.remove(oldRemoteValueID);
            t.RemoteValueID = remoteValueID; 
            FTouchedValues.put(remoteValueID, t);
         }
        }
      }
      
      FModifier = 1;
      FModifierID = -1;
      //see if any touch is in the modifier region
      for(Integer key: FTouches.keySet())
      {
        Touch t = FTouches.get(key);
        if (t.motionY < CModifierPanelHeight)
        {
          FModifierID = (int) (t.motionX / (width / 4));
          switch (FModifierID)
          {
            case 0: FModifier = 0.01; break;
            case 1: FModifier = 0.1; break;
            case 2: FModifier = 10; break;
            case 3: FModifier = 100; break;
          }
        }     
      }
    
      //change values of touched RemoteValues
      //and send messages
      OscBundle bundle = new OscBundle();
      for(String key: FRemoteValues.keySet())
      {
        RemoteValue rm = FRemoteValues.get(key);
        if (FTouchedValues.containsKey(rm.ID))
        {
          Touch t = FTouchedValues.get(rm.ID);
          if (t.Touched)
          {
            rm.changeValue(t.motionX);
            rm.addMessage(bundle);
          }
        }
      }
  
      if (FSendTouches.isChecked())
      {
        for(Integer key: FTouches.keySet())
        {
          Touch t = FTouches.get(key);
          t.addMessage(bundle);
        }
      }
      sendBundle(bundle);  
      break;
    }
  }

  pointerID = me.getPointerId(pointerIndex);
  //any pointer down
  if ((event == MotionEvent.ACTION_DOWN) || (event == MotionEvent.ACTION_POINTER_DOWN))
  {
    y = (int) me.getY(pointerIndex);
    if (y > GValueTop)
      remoteValueID = (int) ((y - GValueTop) / GValueHeight);

    Touch t = new Touch(me, pointerIndex, remoteValueID);
    synchronized(this)
    {
      FTouches.put(pointerID, t);
      FTouchedValues.put(remoteValueID, t);
    }
  }
  //any pointer up
  else if ((event == MotionEvent.ACTION_UP) || (event == MotionEvent.ACTION_POINTER_UP))
  {
    int remoteValueToRelease = -1;
    //remove entry from FTouchedValues and FTouches
    Iterator i = FTouches.entrySet().iterator();
    while (i.hasNext()) 
    {
       Map.Entry entry = (Map.Entry) i.next();
       Touch t = (Touch) entry.getValue();
       if (t.PointerID == pointerID)
       {
         remoteValueToRelease = t.RemoteValueID;
         synchronized(this)
         {
           FTouchedValues.remove(remoteValueToRelease);
           i.remove();       
         }
         break;
       }
    }
    
    //release mouse on RemoteValue
    for(String key: FRemoteValues.keySet())
    {
      RemoteValue rm = FRemoteValues.get(key); 
      if (rm.ID == remoteValueToRelease)
      {
        rm.releaseMouse();
        break;
      }
    }
  }
 
  // If you want the variables for motionX/motionY, mouseX/mouseY etc.
  // to work properly, you'll need to call super.surfaceTouchEvent().
  return super.surfaceTouchEvent(me);
}

void mouseReleased()
{
  FTouches.clear();
  FTouchedValues.clear();
  FModifierID = -1;

  for(String key: FRemoteValues.keySet())
  {
    RemoteValue rm = FRemoteValues.get(key);
    rm.releaseMouse();
  }
}
