package game.forms
{
	import com.bit101.components.Window;
	
	import net.flashpunk.FP;

	public class Form
	{
		protected var form:Window; 
		
		protected var formWidth:Number;
		protected var formHeight:Number;
		
		public function Form(title:String, width:Number, height:Number, draggable:Boolean, show:Boolean)
		{
			// set form size
			formWidth = width;
			formHeight = height;
			
			// set form moveable
			// TODO CRIAR ESTA OPÇÃO NO CONTROLE ORIGINAL - WINDOW 
			//form.draggable = draggable;
			
			// create the form
			form = new Window(FP.engine, (FP.width / 2) - (formWidth/2), (FP.height / 2) - (formHeight/2), title);
			form.setSize(formWidth, formHeight);
			
			// set visibility
			if (show == false)
			{
				hide();
			}
		}
		
		public function show():void
		{
			if (FP.engine.contains(form) == false) 
			{
				FP.engine.addChild(form);
			}
		}
		
		public function hide():void
		{
			if (FP.engine.contains(form)) 
			{
				FP.engine.removeChild(form);
			}
		}
	}
}