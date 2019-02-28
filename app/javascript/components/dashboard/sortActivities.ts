import { IActivity } from "../../models/Activity";
import { ILanguage } from "../../models/Language";
import baseCompare from "../../util/baseCompare";
import intCompare from "../../util/intCompare";
import Activity from "../../models/Activity";

export type SortOption = "Language" | "Book" | "Media" | "Stage";

export interface Sort {
  option: SortOption;
  desc?: boolean;
}

export default function sortActivities(
  sort: Sort,
  activities: IActivity[],
  languages: { [id: string]: ILanguage | undefined }
) {
  let compare: (a: IActivity, b: IActivity) => number;
  switch (sort.option) {
    case "Book":
      compare = (a, b) => intCompare(a.bible_book_id, b.bible_book_id);
      break;
    case "Stage":
      compare = (a, b) =>
        intCompare(Activity.progress(a).percent, Activity.progress(b).percent);
      break;
    case "Media":
      compare = (a, b) => baseCompare(a.name, b.name);
    case "Language":
    default:
      compare = (a, b) =>
        baseCompare(
          languages[a.language_id]!.name,
          languages[b.language_id]!.name
        );
      break;
  }

  const finalCompare = (a: IActivity, b: IActivity) =>
    sort.desc ? compare(b, a) : compare(a, b);

  return [...activities].sort(finalCompare);
}
