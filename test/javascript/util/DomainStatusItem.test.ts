import DomainStatusItem, {
  IDomainStatusItem,
  DataCollections,
  countUnit,
  sortByDate,
  revSortByDate,
  latestItem
} from "../../../app/javascript/models/DomainStatusItem";
import translator, { Locale } from "../../../app/javascript/i18n/i18n";
import {
  domainStatusItemFactory,
  organizationFactory,
  personFactory,
  dsiFactory
} from "../testUtil";
import List from "../../../app/javascript/models/List";
import { IPerson } from "../../../app/javascript/models/Person";
import { emptyPerson } from "../../../app/javascript/reducers/peopleReducer";
import { IOrganization } from "../../../app/javascript/models/Organization";
import { emptyOrganization } from "../../../app/javascript/reducers/organizationsReducer";

// const mockDSI: IDomainStatusItem = {
//   id: 0,
//   language_id: 0,
//   category: "PublishedScripture",
//   subcategory: "Portions",
//   description: "",
//   year: 2000,
//   platforms: "",
//   organization_id: 303,
//   person_id: 404,
//   creator_id: 404,
//   bible_book_ids: [1, 2],
//   completeness: "Draft",
//   details: {},
//   count: 0
// };

const t = translator(Locale.en);

const mockPeople = new List<IPerson>(emptyPerson, [
  personFactory({ id: 404, first_name: "Joe", last_name: "Shmoe" })
]);

const mockOrganizations = new List<IOrganization>(emptyOrganization, [
  organizationFactory({ id: 303, short_name: "MocksRUs" })
]);

test("DSI: platformsStr", () => {
  expect(DomainStatusItem.platformsStr(false, false)).toEqual("");
  expect(DomainStatusItem.platformsStr(false, true)).toEqual("iOS");
  expect(DomainStatusItem.platformsStr(true, true)).toEqual("Android|iOS");
});

test("DSI books", () => {
  expect(DomainStatusItem.books(dsiFactory({}), t)).toEqual("Genesis-Exodus");

  const noBooks = domainStatusItemFactory({ bible_book_ids: [] });
  expect(DomainStatusItem.books(noBooks, t)).toEqual("");

  const corinthians = domainStatusItemFactory({ bible_book_ids: [46, 47] });
  expect(DomainStatusItem.books(corinthians, t)).toEqual(
    "1 Corinthians, 2 Corinthians"
  );

  const gospels = domainStatusItemFactory({ bible_book_ids: [40, 41, 42, 43] });
  expect(DomainStatusItem.books(gospels, t, 2)).toEqual("Matthew-Mark...");
});

test("DSI: personName", () => {
  expect(DomainStatusItem.personNames(dsiFactory({}), mockPeople)).toEqual([
    "Joe Shmoe"
  ]);
  const noJoe = domainStatusItemFactory({ person_ids: [] });
  expect(DomainStatusItem.personNames(noJoe, mockPeople)).toEqual([]);
});

test("DSI: orgName", () => {
  expect(DomainStatusItem.orgNames(dsiFactory({}), mockOrganizations)).toEqual([
    "MocksRUs"
  ]);
  const noOrg = domainStatusItemFactory({ organization_ids: [] });
  expect(DomainStatusItem.orgNames(noOrg, mockOrganizations)).toEqual([]);
});

test("Count Unit", () => {
  DataCollections.forEach(collectionType => {
    expect(countUnit(collectionType).length).toBeGreaterThan(0);
  });
});

test("Sort Items By Date", () => {
  // Items with different years, same year, no year
  const first = dsiFactory({ id: 1, year: undefined });
  const second = dsiFactory({ id: 5, year: 1980 });
  const third = dsiFactory({ id: 2, year: 1990 });
  const fourth = dsiFactory({ id: 3, year: 1990 });
  const fifth = dsiFactory({ id: 6, year: undefined });
  const sampleItems = [fourth, first, third, fifth, second];
  const expected = [first, second, third, fourth, fifth];
  expect(sortByDate(sampleItems)).toEqual(expected);
  expect(latestItem(sampleItems)).toEqual(fifth);
  expect(revSortByDate(sampleItems)).toEqual(expected.reverse());
});
