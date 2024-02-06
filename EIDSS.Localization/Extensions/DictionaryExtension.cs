using System;
using System.Collections.Generic;

namespace EIDSS.Localization.Extensions
{
    public static class DictionaryExtension
    {
        public static void AddRangeNewOnly<TKey, TValue>(this Dictionary<TKey, TValue> dic, Dictionary<TKey, TValue> dicToAdd)
        {
            dicToAdd.ForEach(x =>
            {
                if (!dic.ContainsKey(x.Key))
                    dic.Add(x.Key, x.Value);
            });
        }

        public static void AddRange<TKey, TValue>(this Dictionary<TKey, TValue> dic, Dictionary<TKey, TValue> dicToAdd)
        {
            dicToAdd.ForEach(x => dic.Add(x.Key, x.Value));
        }

        public static void ForEach<T>(this IEnumerable<T> source, Action<T> action)
        {
            foreach (var item in source)
                action(item);
        }
    }
}
