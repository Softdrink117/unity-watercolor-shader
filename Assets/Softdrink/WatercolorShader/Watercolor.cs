using UnityEngine;
using System.Collections;
 
 namespace Softdrink{

	[ExecuteInEditMode]
	[RequireComponent(typeof(Camera))]
	[AddComponentMenu("Image Effects/Softdrink/Watercolor")]
	public class Watercolor : MonoBehaviour {
	 
		public float intensity;
		[Range(0f, 1f)]
		public float hueClip = 0f;
		private Material material;
	 
		void Awake (){
			material = new Material( Shader.Find("Hidden/waterColor_pp") );
		}

		// void OnValidate(){
		// 	material.SetFloat("_HueClip", hueClip);
		// }

		void SetMaterialProperties(){
			material.SetFloat("_HueClip", hueClip);
		}
		
		void OnRenderImage (RenderTexture source, RenderTexture destination){
			// if (hueClip <= 0.003f){
			// 	Graphics.Blit (source, destination);
			// 	return;
			// }
	 
			//material.SetFloat("_HueClip", hueClip);
			Graphics.Blit (source, destination, material);
		}
	}

}