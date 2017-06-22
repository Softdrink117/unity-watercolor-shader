using UnityEngine;
using System.Collections;
 
 namespace Softdrink{

	[ExecuteInEditMode]
	[RequireComponent(typeof(Camera))]
	[AddComponentMenu("Image Effects/Softdrink/Watercolor")]
	public class Watercolor : MonoBehaviour {
	 
		public float intensity;

		[HeaderAttribute("Sampling Settings")]

		[Range(0f, 0.99f)]
		public float lowThreshold = 0f;
		[Range(0.01f, 1.0f)]
		public float highThreshold = 1.0f;

		[HeaderAttribute("Debug")]

		public bool debugSelectionView = false;


		private Material material;

		private bool propertyChange = false;
	 
		void Awake (){
			material = new Material( Shader.Find("Hidden/waterColor_pp") );
			SetMaterialProperties();
		}

		void OnValidate(){
			// Enforce logical values for thresholds
			if(lowThreshold > highThreshold) lowThreshold = highThreshold - 0.001f;
			if(highThreshold < lowThreshold) highThreshold = lowThreshold + 0.001f;

			propertyChange = true;
		}

		void SetMaterialProperties(){
			material.SetFloat("_LowThreshold", lowThreshold);
			material.SetFloat("_HighThreshold", highThreshold);

			if(debugSelectionView){
				material.SetFloat("_DebugSelection", 1f);
				material.EnableKeyword("DEBUG_SELECTION");
			}else{
				material.SetFloat("_DebugSelection", 0f);
				material.DisableKeyword("DEBUG_SELECTION");
			}
		}
		
		void OnRenderImage (RenderTexture source, RenderTexture destination){
			if(propertyChange){
				SetMaterialProperties();
				propertyChange = false;
			}
	 
			Graphics.Blit (source, destination, material);
		}
	}

}