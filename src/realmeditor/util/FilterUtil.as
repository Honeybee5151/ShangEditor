package realmeditor.util
{
   import flash.filters.ColorMatrixFilter;
   
   public class FilterUtil
   {
      
      public static const GREY_COLOR_FILTER_1:Array = [new ColorMatrixFilter(MoreColorUtil.singleColorFilterMatrix(6710886))];
      
      public static const GREY_COLOR_FILTER_2:Array = [new ColorMatrixFilter(MoreColorUtil.singleColorFilterMatrix(4473924))];
       
      
      public function FilterUtil()
      {
         super();
      }
   }
}
