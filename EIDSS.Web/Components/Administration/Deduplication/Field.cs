namespace EIDSS.Web.Components.Administration.Deduplication
{
    public class Field
	{
		public int Index { get; set; }
		public string Key { get; set; }
		public string Value { get; set; }
		public string Label { get; set; }
		public bool Checked { get; set; }
		public bool Disabled { get; set; }
		public string Color { get; set; }

		public Field()
		{
			Index = 0;
			Key = string.Empty;
			Value = string.Empty;
			Label = string.Empty;
			Checked = false;
			Disabled = false;
			Color = string.Empty;
		}
		public Field(Field existingObject)
		{
			Index = existingObject.Index;
			Key = existingObject.Key;
			Value = existingObject.Value;
			Label = existingObject.Label;
			Checked = existingObject.Checked;
			Disabled = existingObject.Disabled;
			Color = existingObject.Color;
		}

		public Field Copy()
		{
			var result = new Field
            {
                Index = Index,
                Key = Key,
                Value = Value,
                Label = Label,
                Checked = Checked,
                Disabled = Disabled,
                Color = Color
            };

            return result;
		}
	}
}
