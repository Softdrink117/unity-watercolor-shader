using UnityEngine;
using System.Collections;
 
 namespace Softdrink{

	[ExecuteInEditMode]
	[RequireComponent(typeof(Camera))]
	[AddComponentMenu("Image Effects/Softdrink/Watercolor")]
	public class Watercolor : MonoBehaviour {
	 
		public float intensity;
		private Material material;
	 
		void Awake ()
		{
			material = new Material( Shader.Find("Hidden/waterColor_pp") );
		}

		void SetMaterialProperties(){

		}
		
		void OnRenderImage (RenderTexture source, RenderTexture destination)
		{
			if (intensity == 0)
			{
				Graphics.Blit (source, destination);
				return;
			}
	 
			material.SetFloat("_bwBlend", intensity);
			Graphics.Blit (source, destination, material);
		}
	}

}