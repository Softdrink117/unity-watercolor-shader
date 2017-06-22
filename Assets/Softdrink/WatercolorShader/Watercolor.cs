using UnityEngine;
using System.Collections;
 
 namespace Softdrink{

	[ExecuteInEditMode]
	[RequireComponent(typeof(Camera))]
	[AddComponentMenu("Image Effects/Softdrink/Watercolor")]
	public class Watercolor : MonoBehaviour {

		public Texture noiseTexture;
	 
	 	[RangeAttribute(0.0f, 0.03f)]
		public float deflection = 1f;

		public float blurRadius = 1f;

		[RangeAttribute(-0.1f, 0.1f)]
		public float speedX = 0.01f;
		[RangeAttribute(-0.1f, 0.1f)]
		public float speedY = 0.01f;

		public Vector4 noiseScaleOffset = new Vector4(1.0f, 1.0f, 0.0f, 0.0f);
		public Vector4 noiseScale = new Vector4(0.1f, 0.1f, 0.0f, 0.0f);
		public Vector4 firstOrderOffset = new Vector4(1.8f, 2.1f, 3.6f, 4.2f);
		public Vector4 secondOrderOffset = new Vector4(2.4f, 1.9f, 3.7f, 2.9f);

		[HeaderAttribute("Sampling Settings")]

		[Range(0f, 0.99f)]
		public float lowThreshold = 0f;
		[Range(0.01f, 1.0f)]
		public float highThreshold = 1.0f;

		[HeaderAttribute("Debug")]

		public bool debugSelectionView = false;


		private Material material;

		private bool propertyChange = false;
		private float stime = 0.0f;
	 
		void Awake (){
			material = new Material( Shader.Find("Hidden/waterColor_pp") );
			SetMaterialProperties();
		}

		void OnValidate(){
			// Enforce logical values for thresholds
			if(lowThreshold > highThreshold) lowThreshold = highThreshold - 0.001f;
			if(highThreshold < lowThreshold) highThreshold = lowThreshold + 0.001f;
			if(blurRadius < 0f) blurRadius = 0f;

			propertyChange = true;
		}

		void Update(){
			stime += Time.unscaledDeltaTime;
			material.SetFloat("_STime", stime);
		}

		void SetMaterialProperties(){
			material.SetTexture("_NoiseTexture", noiseTexture);
			material.SetVector("_NoiseScaleOffset", noiseScaleOffset);

			material.SetFloat("_Deflection", deflection);
			material.SetFloat("_Radius", blurRadius);
			material.SetFloat("_SpeedX", speedX);
			material.SetFloat("_SpeedY", speedY);
			material.SetVector("_Scale", noiseScale);
			material.SetVector("_Offset1", firstOrderOffset);
			material.SetVector("_Offset2", secondOrderOffset);
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